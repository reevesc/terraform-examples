# ECS with EC2
This is an example Terraform configuration that sets up a functional ECS Cluster on EC2 in AWS, with additional support for multiple environments.

This project is intended to be as close to "plug and play" as possible, but will likely require some basic changes to get it up and running in your specific environment. Please keep this in mind and feel free to fork the repo to give yourself a clean space to work in.

Please note that this example does require some working knowledge of Terraform.

## Initial Requirements
The following is a list of requirements you will need to get this infrastructure up and running.

Basic

* Terraform installed on your computer along with some basic knowledge of Terraform commands and how it works.
* Docker and Docker Desktop installed on your computer along with some basic knowledge of Docker commands and how it works.
* An AWS Account.
* AWS CLI installed on your local machine
* An ECR Repoistory with a working docker image pushed to it (discussed further in the "Up and Running" section below)

AWS Specific

You will also need an IAM User with the following permissions:
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

## Project File System Structure
This configuration is broken down into 4 primary directories: global, infrastructure, production, stage.

**global** - This directory includes configurations that should be applied to all environments (stage, production, and any additional environments you might add). 

**infrastructure** - This directory includes your core infrastructure definitions. The configurations defined within this directory are shared between both production and stage and will be called in to them in the form of a module (you won't run run any terraform commands from within this directory).

**production** - This directory includes your production environment configuration files which is mostly just defining and assigning variable values that are specific to the production evironment. When you run `terraform apply` from within this directory, the values you have assigned to the variables in this directory will be passed over to the infrastructure module where they will be used to build out your configuration.

Important - Any variable definitions added to the production directory should also be included in the stage directory. The values can be different, but the definitions themselves should exist in both locations.

**stage** - This is the same concept as the production directory, except that you are defining variable values that are specific to your staging environment. When you run `terraform apply` from within this directory, the values you have assigned to the variables in this directory will be passed over to the infrastructure module where they will be used to build out your staging environment infrastructure.

Important - As with production, any variable definitions added to the stage directory should also be included in the production directory. The values can be different, but the definitions themselves should exist in both locations.

## Up and Running
To get this example up and running within AWS:

### Setup
* Copy the files from the repo (or just fork the repo) to your development environment. 
* Make sure you have your AWS Account created along with an IAM user with the permissions listed in the inital requirements section.
* Configure the AWS CLI with your IAM user access key credentials
  * If this is your only IAM user, you can do this under the 'default' profile. Otherwise, you will want to create a separate profile for this user. In this example, my user profile is named `terraform-example-user`. If you use the same name, you can skip the step below.


### Update AWS CLI Profile References in the file system
If you set your AWS CLI user profile name to anything other than `terraform-example-user` you will need change the references to the profile name within the terraform configuration files. There are 6 references to the profile name that will need to be changed:

* **/global/main.tf** - Located at the top of the document in the `backend` block. Locate and change the value assigned to the `provider` argument.
* **/global/terraform.tfvars** - Locate and change the value of the `provider_profile` variable
* **/stage/main.tf** - Located at the top of the document in the `backend` block. Locate and change the value assigned to the `provider` argument.
* **/stage/terraform.tfvars** - Locate and change the value of the `provider_profile` variable
* **/production/main.tf** - Located at the top of the document in the `backend` block. Locate and change the value assigned to the `provider` argument.
* **/production/terraform.tfvars** - Locate and change the value of the `provider_profile` variable

Be sure to save your changes made to each file.

### ECR Repo Setup
For this step, you need to create an ECR Repository in AWS and push a docker image to it. If you are not familar with how to do this, I've provided a quick run down of the steps involved. If you run into issues here, you might need to do a bit of searching to help you through the process (it's pretty easy if you are familar with AWS).

1. Login to the AWS Management Console and navigate to the ECR (Elastic Container Registry)
section. While you are at it, make sure you set the region you want to build your infrastucture in.
2. Click "Create Repository"
3. Set the repo visibility to Public or Private (depending on your needs)
4. Specify the repository name, and set the Tag Immutability, Image Scanning, and Encryption settings according to your requirements. 
5. Click "Create Repository"
6. Once the repository is created, copy the "Repository Name" and the "Repository URL"
7. Open the `terraform.tfvars` file in both the `stage` and `production` directories. Locate the variable named `ecr_repo_name` and set it's value to the Repository name you copied in step 6.

So at this point you've created an ECR Repository, but it's empty. You need to push an image in to it in order for this configuration to work. If you already have a working image, feel free to use that. If you don't have a working image, for this example, I recommend using an simple HTTP test image from Docker. For reference, I'm going to use [strm/helloworld-http](https://hub.docker.com/r/strm/helloworld-http/tags]). 

Once you have your test image selected, you will need to run the following commands in your terminal to get a copy of the image into your newly created repo:

```
# Set a variable named REPO_URL
export REPO_URL=<your Repository URL from step 6 above>

# Login to AWS ECR
aws ecr get-login-password | docker login --username AWS --password-stdin $REPO_URL

# Pull your test image from Docker, and then push it into your
# ECR Repo on AWS
docker pull --platform linux/amd64 strm/helloworld-http:latest
docker tag strm/helloworld-http:latest $REPO_URL:latest
docker push $REPO_URL:latest
```

If you are using a Mac, be sure to change the platform from `linux/amd64` to `linux/arm64`

Once the image has been pushed into your ECR Repo, you are set to go with this step.

**Note:** You can configure Terraform to create the ECR Repository for you. I have included an example of how you would do this in `infrastructure/ecr.tf`.

Under most circumstances, I prefer to create the repo outside of Terraform and then reference the repo via a data block, so I have configured this repo to use that approach by default.


### Update variable values for Stage and Production
Next we need to update the variable values for the staging and production environments.  

Start by opening the `terraform.tfvars` in the `stage` directory. Update these values according to the needs of your staging environment. 

Repeat this same process for the `terraform.tfvars` in the `production` directory. 


### Build your Infrastructure
At this point in time, you are ready to build your infrastructure. 

#### Global
The build process starts with global. This is going to create the "global" infrastructure resources that all of the environments will utilize.

To create the global resources, open up a terminal and cd into the global directory. Then run the following commands:

```
$ terraform init

# Optional but will show you what resources will be built
$ terraform plan 

$ terraform apply 
```

Once the terraform apply command is finished, you can now move in to building the resources for your stage and/or production environment.


#### Stage & Production
The process for building your stage and production environment resources is the same as global:

Via terminal, cd into the stage (or production) directory and then run:

```
$ terraform init

# Optional but will show you what resources will be built
$ terraform plan 

$ terraform apply 
```

The build process will take longer for the environments as there are more resources that need to be created, but once complete, you should end up with a fully functional environment with EC2 instances running a container with the image you pushed to your ECR repository. You can verify the infrastructure is working by visiting the output url that is displayed after the build process is complete (the output url is the direct url to an Application Load Balancer which was created as part of the build process).


### Additional Configurations

#### Remote State File Management
This configuration comes with the ability to enable remote state file management for terraform. To enable this, you will need to make a few changes to the infrastructure code.

Note that you will only want to make this change **AFTER** your global and environment resources have been created (so, after you have run `terraform apply` on global and one or more environments).

##### Global Configuration Changes
1. Open the `global/main.tf` file
2. Locate and uncomment the `backend` block at the top of the file
3. Make any necessary changes to the `bucket`, `key`, `profile`, and `region` arguments within the block. (See Terraform Documentation for a detailed explanation of what these arguments do).
4. Go to your terminal, cd into the global directory, and then run `terraform init`. Terraform will automatically detect that you wanting to change from local state file management to remote state file management, and will ask you to confirm that you want to make the change. Confirm the change.

Now, repeat the steps above for any of the environment directories you have already deployed. Be sure to pay close attention to the `key` argument in the `backend` block for your environment configurations. The `key` argument specifies the location within your S3 bucket where your environment state file will be stored. If this path is not unique for the environment you are working with, you could end up in a situation where one environment overwrites the state file of another environment. 


##### Adding New Environments
Adding support for a new environment is easy.

1. Copy an existing environment directory/all of its files.
2. Rename the copied directory to the name of your new environment
3. Update the variable values in the `terraform.tfvars` file.
4. Run the terraform commands to build your new environment infrastructure

**Important Note** If you have configured your environments to use remote state file management (see Remote State File Management section above), before you run the commands to build your new environment infrastructure, be sure to comment out the `backend` block **BEFORE** your first run, and then uncomment it **AFTER** the initial build is complete. Then re-run `$ terraform init` to switch the environment over to remote state management.


##### Adding new variables
The variables that have been defined in `variables.tf` and `terraform.tfvars` are the ones that I have found to be most useful in my development work. You may need (or want) to add new variables that are better for your workflow. To do this:

1. Select an environment to configure your new variable. 
2. Define your variable in the `variables.tf` file
3. Set the value of the variable in the `terraform.tfvars` file
4. Add the variable to the `app_infrastructure` module in the environments `main.tf` file.
5. Call the variable within the corresponding infrastructrue file.

**Important Note** When you add a variable to an environment, you will need to add that same variable to all of the other environments you have configured. 

For example: Lets say you define and add a new variable called `my_new_variable` to your stage environment configuration. After you have finished adding the variable to the stage environment files, you will need to repeat steps 1-4 above on your production environment as well. If you have added new environments (in addition to stage and production), you will need to repeat steps 1-4 for those environments as well. 


##### Running container on port other than port 80
Occasionally, you may have a container that communicates on a port other than port 80. You can implement this type of configuration by setting the following variables to the port your container runs on:

* ecs_task_def_container_port
* ecs_task_def_host_port
* lb_tg_port

Note that all of these variables must be set to the same value. For example: If your container runs on port 5001, all 3 variables should be set to 5001.


## Variable Definitions
Variable definitions can be found in the README files in the `global` and `stage` directories.


