# Environment Variables
environment_name      = "stage"
app_name              = "ex-web-app"

# Provider Variables
provider_region       = "us-west-2"
provider_profile      = "terraform-example-user"

# S3 Variables
app_s3_bucket_name    = "ex-app-bucket-name-stage"

# Key Pair Variables
key_pair_name         = "bastion-host-key-pair"

# Domain / Hosted Zone Variables
app_domain_name       = "example.com"
create_dns_zone       = false

# EC2 Instance Variables
ec2_instance_type     = "t3.micro"

# RDS Variables (TODO)
db_name               = "my_db_stage"
db_username           = "my_db_username"
# INSECURE! For example purposes only. Do NOT store your password here.
db_password           = "password" 

# VPC
availability_zone_count = 2

# ECS
ecs_cluster_name      = "app-stage-cluster"
ecs_service_desired_count = 1
ecs_cloudwatch_retention_days = 1

# ASG
asg_min_size          = 1
asg_max_size          = 2

# ECR
ecr_repo_name             = "ex-app-ecr-repo"

# Only used when having Terraform create the ECR Repo
ecr_force_delete          = false
ecr_image_tag_mutability  = "MUTABLE"
ecr_scan_image_on_push    = false

# Task Definition
ecs_task_def_network_mode             = "awsvpc"
ecs_task_def_cpu                      = 256
ecs_task_def_memory                   = 512
ecs_task_def_container_port           = 5000
ecs_task_def_host_port                = 5000
ecs_task_def_container_def_log_region = "us-west-2"

# Load Balancer
lb_tg_port                            = 5000
lb_tg_protocol                        = "HTTP"
lb_tg_target_type                     = "ip"
