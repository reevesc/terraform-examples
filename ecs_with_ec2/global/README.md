# Global Configuration
This is the base configuration for the application infrastructure. It should be run first to ensure everything is setup properly (before staging or production).

## Setup

### AWS IAM User Configuration
To run the global configuration, your AWS IAM User is will need the following permissions enabled:

* AmazonS3FullAccess
* AmazonDynamoDBFullAccess

If you want to manage the AWS Route53 Hosted Zone from within the terraform configuration, you will also need:

* AmazonRoute53FullAccess


### Variables
Variables are located in the variables.tf and terraform.tfvars files. You will need to update these values to match the needs of your specific configuration.

**provider_region** - Used to define the target region you want to deploy your infrastructure to in AWS.

**provider_profile** - For use when you have multiple AWS profiles configured - this will allow you to specify the profile (IAM User) you want to use to build the infrastructure.

**app_s3_bucket_name** - Allows you to specify an S3 bucket name. This is primarly used in conjunction with remote state file management although the bucket can be used for storing other application files.

**app_domain_name** - Used to configure a Route53 Hosted Zone for your application. In order for the configuration to work, you MUST have a hosted zone configured in AWS; however, the hosted zone does NOT need to be created or managed by terraform. If you do NOT want to create the hosted zone via terraform configuration, be sure to comment out the `aws_route53_zone` block in the `global/main.tf` file. 


## Apply the Configuration
To apply the configuration, from inside of the `global` directory, run the following terraform commands:

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



