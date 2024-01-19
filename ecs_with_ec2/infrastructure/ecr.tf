#
# Elastic Container Repository (ECR)
#

#
# If you want terraform to create the ECR repo within the
# configuration, use the block below. Note that when running
# a terraform destroy command, the repository will be destroyed
# along with any images you have pushed to it if force_delete is
# set to true.
#
# If you decide to have terraform create the repo for you, be sure
# to comment out the `aws_ecr_repository` data block at the bottom
# of this file. 
#
# resource "aws_ecr_repository" "ecr_app" {
#   name                 = var.ecr_repo_name
#   image_tag_mutability = var.ecr_image_tag_mutability
#   force_delete         = var.ecr_force_delete

#   # Uncomment to configure ECR encryption
#   # encryption_configuration {
#   #   encryption_type = "AES256" # Either AES256 or KMS
#   # }

#   image_scanning_configuration {
#     scan_on_push = var.ecr_scan_image_on_push
#   }
# }


#
# Use the block below if you have created your ECR repository
# outside of terraform.
#
data "aws_ecr_repository" "ecr_app" {
  name = var.ecr_repo_name
}