locals {
  name_prefix = "${var.project_name}-${var.environment}"
  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

data "terraform_remote_state" "prod" {
  backend = "local"

  config = {
    path = var.prod_state_path
  }
}

module "alb_dev" {
  source = "../../modules/alb"

  name_prefix = var.project_name
  vpc_id      = data.terraform_remote_state.prod.outputs.vpc_id

  target_group_name = "tg-dev"
  target_group_port = 80
  health_check_path = "/dev/"

  create_alb      = false
  create_listener = false
  create_path_rule = true
  path_patterns   = ["/dev/*"]
  path_rule_priority = 100

  existing_alb_arn               = data.terraform_remote_state.prod.outputs.alb_arn
  existing_alb_dns_name          = data.terraform_remote_state.prod.outputs.alb_dns_name
  existing_alb_zone_id           = data.terraform_remote_state.prod.outputs.alb_zone_id
  existing_alb_security_group_id = data.terraform_remote_state.prod.outputs.alb_security_group_id
  existing_listener_arn          = data.terraform_remote_state.prod.outputs.listener_arn

  tags = local.tags
}

module "ecr_dev" {
  source = "../../modules/ecr"

  repository_name = "app-dev"
  tags            = local.tags
}

module "ecs_cluster_dev" {
  source = "../../modules/ecs-cluster"

  cluster_name = "app-dev-cluster"
  tags         = local.tags
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "${local.name_prefix}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${local.name_prefix}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

module "ecs_service_dev" {
  source = "../../modules/ecs-service"

  region          = var.aws_region
  cluster_id      = module.ecs_cluster_dev.cluster_id
  service_name    = "app-dev-service"
  task_family     = "app-dev-task"
  container_name  = "app"
  container_image = "${module.ecr_dev.repository_url}:latest"
  container_port  = 80

  cpu           = 256
  memory        = 512
  desired_count = 1

  minimum_healthy_percent = 100
  maximum_percent         = 200

  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  log_group_name     = module.ecs_cluster_dev.log_group_name

  vpc_id                = data.terraform_remote_state.prod.outputs.vpc_id
  private_subnet_ids    = data.terraform_remote_state.prod.outputs.private_subnet_ids
  target_group_arn      = module.alb_dev.target_group_arn
  alb_security_group_id = data.terraform_remote_state.prod.outputs.alb_security_group_id

  tags = local.tags
}
