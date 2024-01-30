terraform {
  #
  # To enable the remote backed state management via S3, run
  # terraform apply on this configuration first, then 
  # uncomment this section and re-run terraform init.
  #
  # backend "s3" {
  #   bucket         = "ex-app-bucket-name"
  #   key            = "app/production/tf-state-file/terraform.tfstate"
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

module "app_infrastructure" {
  source = "../infrastructure"

  # Input Variables
  app_name                = var.app_name
  environment_name        = var.environment_name
  
  app_s3_bucket_name      = var.app_s3_bucket_name
  
  key_pair_name           = var.key_pair_name

  app_domain_name         = var.app_domain_name
  create_dns_zone         = var.create_dns_zone

  ec2_instance_type       = var.ec2_instance_type
  
  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = var.db_password

  availability_zone_count = var.availability_zone_count

  ecs_cluster_name              = var.ecs_cluster_name
  ecs_service_desired_count     = var.ecs_service_desired_count
  ecs_cloudwatch_retention_days = var.ecs_cloudwatch_retention_days

  asg_min_size            = var.asg_min_size
  asg_max_size            = var.asg_max_size

  ecr_repo_name             = var.ecr_repo_name
  ecr_force_delete          = var.ecr_force_delete
  ecr_image_tag_mutability  = var.ecr_image_tag_mutability
  ecr_scan_image_on_push    = var.ecr_scan_image_on_push

  ecs_task_def_network_mode   = var.ecs_task_def_network_mode
  ecs_task_def_cpu            = var.ecs_task_def_cpu
  ecs_task_def_memory         = var.ecs_task_def_memory
  ecs_task_def_container_port = var.ecs_task_def_container_port
  ecs_task_def_host_port      = var.ecs_task_def_host_port
  ecs_task_def_container_def_log_region = var.ecs_task_def_container_def_log_region

  lb_tg_port                  = var.lb_tg_port
  lb_tg_protocol              = var.lb_tg_protocol
  lb_tg_target_type           = var.lb_tg_target_type
}
