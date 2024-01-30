#
# Provider Variables
#
variable "provider_region" {
  description = "Specify the AWS provider region"
  type        = string
  default     = "us-west-2"
}

variable "provider_profile" {
  description = "Specify the AWS provider profile"
  type        = string
}


#
# S3 Variables
#
variable "app_s3_bucket_name" {
  description = "Specify the name of the S3 bucket you would like to use for the app."
  type        = string
}


#
# Domain / Hosted Zone Variables
#
variable "app_domain_name" {
  description = "Specify the name of your application domain name to be configured in AWS"
  type        = string
  default     = "example.com"
}
