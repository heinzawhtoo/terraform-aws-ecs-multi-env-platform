resource "aws_ecs_cluster" "this" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(var.tags, {
    Name = var.cluster_name
  })
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.cluster_name}"
  retention_in_days = 30

  tags = var.tags
}
