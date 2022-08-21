# Create a KMS key for S3 bucket encryption
resource "aws_kms_key" "mykey" {
  description             = "This key will be used to encrypt bucket objects"
  key_usage = "ENCRYPT_DECRYPT"
  is_enabled = true
  enable_key_rotation = true
  multi_region = false
  deletion_window_in_days = 7
}

# Create an alias for KMS Key
resource "aws_kms_alias" "mykey-alias" {
  name = "alias/alvin-key-kms"
  target_key_id = aws_kms_key.mykey.key_id
}

