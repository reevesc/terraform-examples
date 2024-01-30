#
# S3 Resources
#

# Create an S3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket        = var.app_s3_bucket_name
  force_destroy = true
}

# Enable Versioning on the Bucket
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable Server Side Encryption on the Bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_crypto_conf" {
  bucket = aws_s3_bucket.bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
