#
# Cloud Watch Logs
#
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.app_name}-${var.environment_name}"
  retention_in_days = var.ecs_cloudwatch_retention_days 
}
