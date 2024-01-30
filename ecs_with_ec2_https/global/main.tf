terraform {
  #
  # The aws_dynamodb_table resource must be created
  # before you can enable the remote S3 backend for the 
  # state file. To enable the remote backed state management 
  # via S3, run terraform apply on this configuration first, 
  # then uncomment this section and re-run terraform init.
  #
  # backend "s3" {
  #   bucket         = "ex-app-bucket-name"
  #   key            = "app/global/tf-state-file/terraform.tfstate"
  #   dynamodb_table = "terraform-state-locking"
  #   encrypt        = true
  #   profile        = "terraform-example-user"
  #   region         = "us-west-2"
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.provider_region
  profile = var.provider_profile
}

#
# S3 Bucket 
#
# Create the S3 bucket which will be used within the application
# We'll first use it to store the state file for the remote
# backend configuration, however, the S3 bucket can be used for
# other purposes. 
#
resource "aws_s3_bucket" "applicaton_s3_bucket" {
  bucket          = var.app_s3_bucket_name
  force_destroy   = true
}

resource "aws_s3_bucket_versioning" "terraform_bucket_versioning" {
  bucket      = aws_s3_bucket.applicaton_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_state_encrypt_conf" {
  bucket      = aws_s3_bucket.applicaton_s3_bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#
# Dynamo DB Table (for remote state file management)
#
# In order for the remote backend to work with AWS
# the hash key MUST be set to LockID. That's a key
# attribute that needs to match this exactly in order 
# for this to work properly with the remote S3 backend.
#
resource "aws_dynamodb_table" "terraform_locks" {
  name            = "terraform-state-locking"
  billing_mode    = "PAY_PER_REQUEST"
  hash_key        = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

#
# Route53 Hosted Zone
#
# Configure the hosted zone for your application domain
#
resource "aws_route53_zone" "primary" {
  name = var.app_domain_name
}