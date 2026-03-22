aws_region   = "ap-southeast-1"
project_name = "terraform-aws-ecs-multi-env-platform"
environment  = "prod"

vpc_cidr = "10.20.0.0/16"

availability_zones = [
  "ap-southeast-1a",
  "ap-southeast-1b"
]

public_subnet_cidrs = [
  "10.20.1.0/24",
  "10.20.2.0/24"
]

private_subnet_cidrs = [
  "10.20.11.0/24",
  "10.20.12.0/24"
]

enable_nat_gateway = true

app_port = 3000

alb_ingress_cidr_blocks = [
  "0.0.0.0/0"
]

health_check_path = "/health"

ecs_log_retention_in_days = 30

enable_container_insights = true

ecs_name_prefix     = "tfecs"
ecr_force_delete    = false
container_name      = "app"
container_image_tag = "bootstrap"

task_cpu    = 256
task_memory = 512

container_environment = {
  APP_ENV = "prod"
}