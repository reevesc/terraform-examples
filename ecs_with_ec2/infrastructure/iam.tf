#
# IAM Role and Policy Configurations
#

#
# ECS Policy and Roles for EC2 
#

# Define the policy
data "aws_iam_policy_document" "ecs_ec2_iam_policy_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Create the role and attach the policy to it
resource "aws_iam_role" "ecs_ec2_iam_role" {
  name_prefix        = "${var.app_name}-${var.environment_name}-ecs-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_ec2_iam_policy_doc.json
}

# Attach managed policy to the role
resource "aws_iam_role_policy_attachment" "ecs_ec2_iam_role_policy" {
  role       = aws_iam_role.ecs_ec2_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Create an instance profile (used to pass the role to the ec2 instance)
resource "aws_iam_instance_profile" "ecs_ec2_iam_profile" {
  name_prefix = "${var.app_name}-${var.environment_name}-ecs-profile"
  path        = "/ecs/instance/"
  role        = aws_iam_role.ecs_ec2_iam_role.name
}


#
# Policy and Roles for ECS
#
data "aws_iam_policy_document" "ecs_policy_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name_prefix        = "${var.app_name}-${var.environment_name}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_policy_doc.json
}

resource "aws_iam_role" "ecs_exec_role" {
  name_prefix        = "${var.app_name}-${var.environment_name}-ecs-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "ecs_exec_role_policy" {
  role       = aws_iam_role.ecs_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}