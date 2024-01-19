#
# Auto Scaling Group(s) Configuration
#

# Create auto scaling group for 
resource "aws_autoscaling_group" "ecs_asg" {
  name_prefix               = "${var.app_name}-${var.environment_name}-asg-"
  vpc_zone_identifier       = aws_subnet.public[*].id
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  health_check_grace_period = 0
  health_check_type         = "EC2"
  protect_from_scale_in     = false

  launch_template {
    id      = aws_launch_template.ecs_ec2.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.ecs_cluster_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}