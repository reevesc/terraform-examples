#
# Environment Variables
#
variable "environment_name" {
  description = "Specify the environment name (development, stage, production, etc.)"
  type        = string
  default     = "stage"
}

variable "app_name" {
  description = "Provide a short name for the application (single word, 10 chars max, alpha, dashes, underscores only)"
  type        = string
  default     = "web-app"

  validation {
    condition = length(var.app_name) <= 10 && can(regex("^[0-9A-Za-z_-]+$", var.app_name))
    error_message = "Application Name must be less than 10 characters"
  }
}


#
# S3 Variables
#
variable "app_s3_bucket_name" {
  description = "Specify the name of the S3 bucket you would like to use for the app."
  type        = string
}


#
# Key Pair Variables
#
variable "key_pair_name" {
  description = "Specify the name of an existing key pair to attach to your EC2 instances on launch."
  type        = string
}


#
# Domain / Hosted Zone Variables
#
variable "app_domain_name" {
  description = "Specify the name of your application domain name to be configured in AWS."
  type        = string
  default     = "example.com"
}

# Create DNS Zone? 
variable "create_dns_zone" {
  description = "If true, create new route53 zone, if false read existing route53 zone"
  type        = bool
  default     = false
}


#
# EC2 Instance Variables
#
variable "ec2_instance_type" {
  description = "Specify your EC2 instance type."
  type        = string
  default     = "t3.micro"
}


#
# RDS Variables
#
variable "db_name" {
  description = "Specify your database name."
  type        = string
}

variable "db_username" {
  description = "Specify your database username."
  type        = string
  default     = "my_db_user"
}

variable "db_password" {
  description = "Specify your database password."
  type        = string
  sensitive   = true
}


#
# VPC
#
variable "availability_zone_count" {
  description = "Specify the number of availablity zones to configure within the VPC (minimum of 2)."
  type        = number
  default     = 2
  validation {
    condition     = var.availability_zone_count >= 2
    error_message = "Availability zone count must be >= 2."
  }
}


#
# ECS
#
variable "ecs_cluster_name" {
  description = "Provide a name for the ECS Cluster"
  type = string

  validation {
    condition = length(var.ecs_cluster_name) <= 255
    error_message = "Cluster name must be less than 255 characters"
  }
}

variable "ecs_service_desired_count" {
  description = "Enter the desired number of ECS Services you would like to have. (default = 1)"
  type = number
  default = 1

  validation {
    condition = var.ecs_service_desired_count > 0
    error_message = "ECS Service desired_count must be greater than 0."
  }
}

variable "ecs_cloudwatch_retention_days" {
  description = "Specify number of days for cloud watch logs to be retained. (default = 7)"
  type        = number
  default     = 7
}


#
# Auto Scaling Group
#
variable "asg_min_size" {
  description = "Specify the minimum number of instances to be created by the Auto Scaling Group. (default = 1)"
  type        = number
  default     = 1

  validation {
    condition = var.asg_min_size > 0
    error_message = "Minimum Size of auto scaling group must be greater than 0."
  }
}

variable "asg_max_size" {
  description = "Specify the maximum number of instances to be created by the Auto Scaling Group. (default = 2)"
  type        = number
  default     = 2

  validation {
    condition = var.asg_max_size > 1
    error_message = "Maximum Size of auto scaling group must be greater than 1."
  }
}


#
# ECR
#
variable "ecr_repo_name" {
  description = "Specify the name of your ECR Repository."
  type        = string
}

variable "ecr_force_delete" {
  description = "Specify whether or not the ECR repo should be deleted even if it contains images (default = false)"
  type        = bool
  default     = false
}

variable "ecr_image_tag_mutability" {
  description = "Specify the tag mutability for the ECR repo. Must be either MUTABLE or IMMUTABLE (default = MUTABLE)"
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.ecr_image_tag_mutability)
    error_message = "Image tag mutability must be either MUTABLE or IMMUTABLE"
  }
}

variable "ecr_scan_image_on_push" {
  description = "Specify whether or not ECR images should be scanned on push (default = false)"
  type        = bool
  default     = false
}


#
# ECS Task Definition
#
variable "ecs_task_def_network_mode" {
  description = "Specify the task definition network mode"
  type        = string
  default     = "awsvpc"

  validation {
    condition     = contains(["none", "bridge", "awsvpc", "host"], var.ecs_task_def_network_mode)
    error_message = "Network mode must be one of: none, bridge, awsvpc, and host"
  }
}

variable "ecs_task_def_cpu" {
  description = "Specify number of CPU units to be used by the task definition. (default = 256)"
  type        = number
  default     = 256
}

variable "ecs_task_def_memory" {
  description = "Specify amount of memory to be used by the task definition. (default = 256)"
  type        = number
  default     = 256
}

variable "ecs_task_def_container_port" {
  description = "Specify the task definition container port"
  type        = number
}

variable "ecs_task_def_host_port" {
  description = "Specify the task definition host port"
  type        = number
}

variable "ecs_task_def_container_def_log_region" {
  description = "Specify the container definition log region"
  type        = string
}


#
# Load Balancer
#
variable "lb_tg_port" {
  description = "Specify the load balancer target group port (default = 80)"
  type        = number
  default     = 80

  validation {
    condition     = var.lb_tg_port >= 0 && var.lb_tg_port <= 65535
    error_message = "Load balancer target group port must be between 0 and 65535"
  }
}

variable "lb_tg_protocol" {
  description = "Specify the load balancer target group protocol. (default = HTTP)"
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS", "TCP", "TCP_UDP", "TLS", "UDP"], var.lb_tg_protocol)
    error_message = "Load balancer target group protocol must of one of: HTTP, HTTPS, TCP, TCP_UDP, TLS, UDP"
  }
}

variable "lb_tg_target_type" {
  description = "Specify load balancer target group target type. (default = ip)"
  type        = string
  default     = "ip"

  validation {
    condition     = contains(["ip", "instance"], var.lb_tg_target_type)
    error_message = "Load balancer target group target_type must of one of: ip, or instance"
  }
}
