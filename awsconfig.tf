# Create a configuration recorder
resource "aws_config_configuration_recorder" "alvin_config_recorder" {
  role_arn = aws_iam_role.config_iam_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }
}

# Setup config delivery channel
resource "aws_config_delivery_channel" "alvin_delivery_channel" {
  s3_bucket_name = aws_s3_bucket.alvin_config_bucket.id
  depends_on     = [aws_config_configuration_recorder.alvin_config_recorder]
}

# Setup config recorder status
resource "aws_config_configuration_recorder_status" "alvin_config_recorder_status" {
  name       = aws_config_configuration_recorder.alvin_config_recorder.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.alvin_delivery_channel]
}

# Create S3 Bucket for AWS Config
resource "aws_s3_bucket" "alvin_config_bucket" {
  bucket = "alvin-config-bucket"

  tags = {
    Name        = "alvin-config-bucket"
    Terraform   = "Yes"
    Environment = "Dev"
  }
}

# Prepare Config IAM Role
resource "aws_iam_role" "config_iam_role" {
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : ["config.amazonaws.com"]
          },
          "Effect" : "Allow",
        }
      ]
    }
  )
}

# Attach IAM Role Policy for Config IAM Role
resource "aws_iam_role_policy_attachment" "config_iam_role_policy_role_attachment" {
  role       = aws_iam_role.config_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

# Attach IAM Role Policy to allow access to alvin_config_bucket
resource "aws_iam_role_policy" "config_iam_role_config_bucket_role_attachment" {
  name = "allow-access-to-alvin-config-bucket"
  role = aws_iam_role.config_iam_role.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:PutObject"
          ],
          "Resource" : [
            "${aws_s3_bucket.alvin_config_bucket.arn}/*"
          ],
          "Condition" : {
            "StringLike" : {
              "s3:x-amz-acl" : "bucket-owner-full-control"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:GetBucketAcl"
          ],
          "Resource" : "${aws_s3_bucket.alvin_config_bucket.arn}"
        }
      ]
    }
  )
}

# Add AWS Config Rule to check on EBS Encrypted Volumes
resource "aws_config_config_rule" "EBS_encrypted_vol_config_rule" {
  name        = "encrypted-volumes"
  description = "Checks whether the EBS volumes that are in an attached state are encrypted. If you specify the ID of a KMS key for encryption using the kmsId parameter, the rule checks if the EBS volumes in an attached state are encrypted with that KMS key."

  depends_on = [
    aws_config_configuration_recorder.alvin_config_recorder
  ]

  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }
  scope {
    compliance_resource_types = ["AWS::EC2::Volume"]
  }
}

# Add AWS Config Rule to check whether IAM Access key has been rotated within the past 90 days
resource "aws_config_config_rule" "IAM_access_key_rotation_config_rule" {
  name             = "access-keys-rotated"
  description      = "A config rule that checks whether the active access keys are rotated within the number of days specified in maxAccessKeyAge. The rule is NON_COMPLIANT if the access keys have not been rotated for more than maxAccessKeyAge number of days."
  input_parameters = "{\"maxAccessKeyAge\":\"90\"}"

  depends_on = [
    aws_config_configuration_recorder.alvin_config_recorder
  ]

  source {
    owner             = "AWS"
    source_identifier = "ACCESS_KEYS_ROTATED"
  }
  scope {
    compliance_resource_types = []
  }
}

# Add AWS Config rule to ensure that required tags
resource "aws_config_config_rule" "required_tags_config_rule" {
  name             = "required-tags"
  description      = "A Config rule that checks whether your resources have the tags that you specify. For example, you can check whether your EC2 instances have the 'CostCenter' tag. Separate multiple values with commas."
  input_parameters = "{\"tag1Key\": \"Name\"}"

  depends_on = [
    aws_config_configuration_recorder.alvin_config_recorder
  ]

  source {
    owner             = "AWS"
    source_identifier = "REQUIRED_TAGS"
  }
  scope {
    compliance_resource_types = ["AWS::EC2::Instance", "AWS::EC2::InternetGateway", "AWS::EC2::RouteTable", "AWS::EC2::SecurityGroup", "AWS::EC2::Subnet", "AWS::EC2::VPC", "AWS::S3::Bucket"]
  }
}
