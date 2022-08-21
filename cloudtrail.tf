# Get my AWS caller identity / Retrieves my connection status and credentials
data "aws_caller_identity" "current" {}



# Create an S3 bucket to store cloudtrail logs
resource "aws_s3_bucket" "alvin_trail_bucket" {
  bucket        = "alvin-trail-bucket"
  force_destroy = true

  tags = {
    Name = "alvin-trail-bucket"
  }
}

# Enable S3 bucket server side encryption config for AWS Cloudtrail
resource "aws_s3_bucket_server_side_encryption_configuration" "alvin_trail_bucket_encryption" {
  bucket = aws_s3_bucket.alvin_trail_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}


# Attach S3 bucket policy
resource "aws_s3_bucket_policy" "alvin_trail_bucket_policy" {
  bucket = aws_s3_bucket.alvin_trail_bucket.id

  depends_on = [
    aws_s3_bucket.alvin_trail_bucket
  ]

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.alvin_trail_bucket.arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.alvin_trail_bucket.arn}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

# Create my custom cloudtrail
resource "aws_cloudtrail" "alvin_cloudtrail" {
  name                          = "alvin_capstone_trail"
  s3_bucket_name                = aws_s3_bucket.alvin_trail_bucket.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = false

  depends_on = [
    aws_s3_bucket_policy.alvin_trail_bucket_policy
  ]

  tags = {
    Name = "alvin_cloudtrail"
  }
}

