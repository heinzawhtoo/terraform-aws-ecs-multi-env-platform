locals {
  name_prefix = "${var.project_name}-${var.environment}"
  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "network" {
  source = "../../modules/network"

  name_prefix = var.project_name
  vpc_cidr    = "10.0.0.0/16"
  public_subnet_cidrs = {
    "${var.aws_region}a" = "10.0.1.0/24"
    "${var.aws_region}b" = "10.0.2.0/24"
  }
  private_subnet_cidrs = {
    "${var.aws_region}a" = "10.0.11.0/24"
    "${var.aws_region}b" = "10.0.12.0/24"
  }

  tags = local.tags
}

module "alb_prod" {
  source = "../../modules/alb"

  name_prefix      = var.project_name
  vpc_id           = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids

  target_group_name = "tg-prod"
  target_group_port = 80
  health_check_path = "/"

  create_alb      = true
  create_listener = true

  tags = local.tags
}

module "ecr_prod" {
  source = "../../modules/ecr"

  repository_name = "app-prod"
  tags            = local.tags
}

module "ecs_cluster_prod" {
  source = "../../modules/ecs-cluster"

  cluster_name = "app-prod-cluster"
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

module "ecs_service_prod" {
  source = "../../modules/ecs-service"

  region          = var.aws_region
  cluster_id      = module.ecs_cluster_prod.cluster_id
  service_name    = "app-prod-service"
  task_family     = "app-prod-task"
  container_name  = "app"
  container_image = "${module.ecr_prod.repository_url}:latest"
  container_port  = 80

  cpu           = 512
  memory        = 1024
  desired_count = 2

  minimum_healthy_percent = 100
  maximum_percent         = 200

  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  log_group_name     = module.ecs_cluster_prod.log_group_name

  vpc_id                = module.network.vpc_id
  private_subnet_ids    = module.network.private_subnet_ids
  target_group_arn      = module.alb_prod.target_group_arn
  alb_security_group_id = module.alb_prod.alb_security_group_id

  tags = local.tags
}

module "iam_github_oidc" {
  source = "../../modules/iam-github-oidc"

  github_org       = var.github_org
  github_repo      = var.github_repo
  allowed_branches = ["dev", "main"]
  role_name        = "${var.project_name}-github-oidc-role"
  passrole_arns = [
    aws_iam_role.ecs_task_execution.arn,
    aws_iam_role.ecs_task_role.arn
  ]

  tags = local.tags
}
