#
# ECS Cluster Definition
#

# Create a cluster and specify the name
#   Additional arguments can be applied. See Terraform docs for complete list.
resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name
}