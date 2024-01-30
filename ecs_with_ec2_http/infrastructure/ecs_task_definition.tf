#
# Task Definition
#

# Create the ecs task definition
resource "aws_ecs_task_definition" "app" {
  family             = "${var.app_name}-${var.environment_name}"
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_exec_role.arn
  network_mode       = var.ecs_task_def_network_mode
  cpu                = var.ecs_task_def_cpu
  memory             = var.ecs_task_def_memory

  container_definitions = jsonencode([
    # ECR Container 1
    {
      name         = "${var.app_name}-${var.environment_name}",
      image        = "${data.aws_ecr_repository.ecr_app.repository_url}:latest",
      essential    = true,
      portMappings = [
        { 
          containerPort = var.ecs_task_def_container_port, 
          hostPort      = var.ecs_task_def_host_port 
        }
      ],

      environment = [
        { 
          name  = "${var.environment_name}",
          value = "${var.environment_name}"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-region"        = var.ecs_task_def_container_def_log_region,
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name,
          "awslogs-stream-prefix" = "app"
        }
      },
    }
  ])
}