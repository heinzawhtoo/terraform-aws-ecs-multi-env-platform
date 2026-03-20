module "vpc" {
  source = "../../modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
  common_tags          = local.common_tags
}

module "security_groups" {
  source = "../../modules/security_groups"

  project_name            = var.project_name
  environment             = var.environment
  vpc_id                  = module.vpc.vpc_id
  app_port                = var.app_port
  alb_ingress_cidr_blocks = var.alb_ingress_cidr_blocks
  common_tags             = local.common_tags
}

module "cloudwatch_logs" {
  source = "../../modules/cloudwatch_logs"

  project_name      = var.project_name
  environment       = var.environment
  retention_in_days = var.ecs_log_retention_in_days
  common_tags       = local.common_tags
}

module "ecs_cluster" {
  source = "../../modules/ecs_cluster"

  project_name              = var.project_name
  environment               = var.environment
  enable_container_insights = var.enable_container_insights
  common_tags               = local.common_tags
}

module "alb" {
  source = "../../modules/alb"

  name_prefix           = var.alb_name_prefix
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
  app_port              = var.app_port
  health_check_path     = var.health_check_path
  common_tags           = local.common_tags
}