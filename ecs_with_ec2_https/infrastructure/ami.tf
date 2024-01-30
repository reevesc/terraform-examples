#
# AMI Configurations
#

# Specify the Amazon ECS Image (optimized image for ECS and EC2)
data "aws_ssm_parameter" "ecs_ec2_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}