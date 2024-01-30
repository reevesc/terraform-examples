#
# Launch Template
#

# Create the launch template for EC2 instances
resource "aws_launch_template" "ecs_ec2" {
  name_prefix            = "${var.app_name}-${var.environment_name}-ec2-"
  image_id               = data.aws_ssm_parameter.ecs_ec2_ami.value
  instance_type          = var.ec2_instance_type
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]

  # Attach key pair
  key_name               = data.aws_key_pair.key_pair.key_name

  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs_ec2_iam_profile.arn
  }
  
  monitoring {
    enabled = true 
  }

  user_data = base64encode(<<-EOF
      #!/bin/bash
      echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config;
    EOF
  )
}