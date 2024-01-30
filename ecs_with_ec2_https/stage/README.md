# Stage Configuration (and all other environments)
This is the stage configuration for the application infrastructure. It should be run AFTER the global configuration has been run.

## Setup

### AWS IAM User Configuration
To run the stage configuration, your AWS IAM User is will need the following permissions enabled:

  * AmazonDynamoDBFullAccess
  * AmazonEC2ContainerRegistryFullAccess
  * AmazonEC2FullAccess
  * AmazonECS_FullAccess
  * AmazonS3FullAccess
  * AWSCertificateManagerFullAccess
  * CloudWatchLogsFullAccess
  * IAMFullAccess

If you want to manage the AWS Route53 Hosted Zone from within the terraform configuration, you will also need:

  * AmazonRoute53FullAccess


### Up and running
To get this example configuration up and running, do the following:

1. If haven't already done so, run the `global` configuration first (see `global/README.md` for more information)
2. Create an IAM user in AWS with the permissions listed above (you can use the same IAM user that you used for the global configuration if you would like to. Just make sure to add the permissions listed above).
3. If you haven't already done so, create an ECR Repository in AWS and push a working container image to it. 
4. Update the variable values set in the `terraform.tfvars` of this folder to match the needs of your environment and your application. (see "Variables" section below for variable definitions).
5. Once all of the steps above are complete, you can then move on to building out this configuration (see "Apply the Configuration" section below.)

## Variables
Variables are located in the variables.tf and terraform.tfvars files located in the environment directory you are working with (for example: `/stage/variables.tf` or `/production/variables.tf`)

Below is a list of the available variables along with a description of what each one does. Before running an environment configuration, you will need to update the values of these variables to meet the requirements of your application.

Note: If this configuration does not give you variable access to a value you need to control, just add a new variable to your configuration. 

### Environment Variables
**environment_name** - (String) Specifies the name of this specific working environment (production, stage, development, etc.). 
Notes:
* You should always use "production" for your production environment.
* All other environment names should be a single word with lowercase characters. With the exception of production, the value specified here will be used to create a subdomain for your application within the hosted zone.  

**app_name** - (String) A short name of your application (10 characters or less). Used in tags and resource names to help you identify which resources apply to this specific application.  


### Provider Variables
**provider_region** - (String) Used to define the target region you want to deploy your infrastructure to in AWS.  

**provider_profile** - (String) For use when you have multiple AWS profiles configured - this will allow you to specify the profile (IAM User) you want to use to build the infrastructure.


### S3 Variables
**app_s3_bucket_name** - (String) Allows you to specify an S3 bucket name. This is primarly used in conjunction with remote state file management although the bucket can be used for storing other application files.

### Key Pair Variables
**key_pair_name** - (String) Specify the name of the key pair that should be attached to your EC2 instances when they are created. You will need to create the key pair record directly within the AWS Management Console (be sure to keep your .pem or .ppk files stored in a secure location).

The key pair can be used to connect to your EC2 instance via Bastion Host should you ever need to troubleshoot issues with the containers running within the instance(s).

### Domain / Hosted Zone Variables
**app_domain_name** - (String) This is the domain name your application will be running under. The value you specify here will be used to create a hosted zone, DNS records, and an SSL Certificate.

**create_dns_zone** - (Boolean). If you created a Hosted Zone/DNS Zone record in your global configuration, set this value to `false`. If you did not create a Hosted Zone within the global configuration and would like to create one for this environment, set this value to `true`. (default = false)

### EC2 Instance Variables
**ec2_instance_type** - (String) Specify the type of ec2 instance(s) that should be created by the launch template (e.g. t3.micro, t3.small, t3.large, etc.)

### VPC
**availability_zone_count** - (Number) Specify the number of availability zones you want to work with in the desired region.  

### ECS
**ecs_cluster_name** - (String) Specify the name you would like to assign to your ECS Cluster.  

**ecs_service_desired_count** - (Number) Specify the desired number of instances of the task definition to place and keep running.  

**ecs_cloudwatch_retention_days** - (Number) Specify the number of days that ecs cloudwatch logs should be retained.

### ASG
**asg_min_size** - (Number) Specify the minimum size of the auto scaling group.

**asg_max_size** - (Number) Specify the maximum size of the auto scaling group.

### ECR
**ecr_repo_name** - (String) Specify the name of the ECR Repository to include in the container definiton of the ecs task definition.

**The variables below are only used when having Terraform create the ECR repo (See stage/ecr.tf for more info)**

**ecr_force_delete** - (Boolean) Specifies whether or not the ECR Repoistory (as created by Terraform) should be destroyed if it has existing images pushed to it. If set to true, the ECR repo will be deleted even if it has images pushed to it. If set to false, the repo will NOT be deleted if images have been pushed to it.

**ecr_image_tag_mutability** - (String) Specify the tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE. Defaults to `MUTABLE`.

**ecr_scan_image_on_push** - (Boolean) Specify whether or not ECR repo images should be scanned on when they are pushed into the repo. Defaults to `false`.

### Task Definition

**ecs_task_def_network_mode** - (String) Specify the network mode of the task definition. Note that AWS task definitions do accept more than one network mode type, however, this specific configuration has only been tested with `awsvpc`. If using a network mode other than `awsvpc` additional modifications will need to be made to get this configuration working as you need it. Defaults to `awsvpc`.

**ecs_task_def_cpu** - (Number) Specify the number of cpu units used by the task definition.

**ecs_task_def_memory** - (Number) Specify the amount (in MiB) of memory used by the task definition

**ecs_task_def_container_port** - (Number) Specify the container port number.

**ecs_task_def_host_port** - (Number) Specify the host port number.

**ecs_task_def_container_def_log_region** - (String) Specify the AWS region where the container definition logs should be stored.

### Load Balancer
**lb_tg_port** - (Number) Specify the port on which load balancer targets receive traffic (hint: you usually want this to match the port defined in `ecs_task_def_container_port`).

**lb_tg_protocol** - (String) Specify the protocol to use for routing traffic to the targets. Defaults to HTTP

**lb_tg_target_type** - (String) Type of target that you must specify when registering targets with this target group. This configuration defaults to and is tested with `ip`, `instance` is also available but may require additional changes to this configuration.



## Apply the Configuration
To apply the configuration, from inside of the `stage` directory (or the directory environment you are working on), run the following terraform commands:

Important Note: You need to apply the `global` configuration BEFORE running these commands. If you haven't read over `global/README.md` do that before proceeding.

```
$ terraform init
$ terraform plan
$ terraform apply
```

### Remote State Management
If you plan to utilize remote state management via S3, after running the terraform commands noted above, you will also need to uncomment the backend block at the top of the main.tf file and then re-run `$ terraform init` to trigger the local state file to the S3 bucket. 

Important Note: If you have changed the value of the `bucket`, `key`, `region`, and `profile` argument values to ensure they match your desired configuration (usage of variables is not allowed in the backend block, so those values will not be automatically changed when you modify variable values).


## Destroying the Configuration

#### Without Remote State Management Enabled
To destroy the configuration WITHOUT remote state file management enabled, run the following command from within the `global` directory:

```
$ terraform destroy
```

#### With Remote State Management Enabled
To destroy the configuration WITH remote state file management enabled, you will need to perform the following steps:

1. Comment out the backend block at the top of the main.tf file.
2. Run `$ terraform init` and approve the change to the configured state management.

AFTER the two steps above have been performed, you can then destroy the configuration as usual within terraform:

```
$ terraform destroy
```
