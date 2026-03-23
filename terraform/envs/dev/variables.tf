variable "aws_region" {
  description = "AWS region for the dev environment"
  type        = string
}

variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to create a NAT gateway"
  type        = bool
  default     = true
}

variable "app_port" {
  description = "Application port for ECS tasks"
  type        = number
}

variable "alb_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to access the ALB"
  type        = list(string)
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
}

variable "ecs_log_retention_in_days" {
  description = "CloudWatch log retention in days"
  type        = number
}

variable "enable_container_insights" {
  description = "Enable ECS container insights"
  type        = bool
  default     = true
}

variable "alb_name_prefix" {
  description = "Short prefix used for ALB resources with AWS name length limits"
  type        = string
  default     = "tfecs"
}

variable "ecs_name_prefix" {
  description = "Short prefix used for ECS-related IAM/resource names with AWS length limits"
  type        = string
  default     = "tfecs"
}

variable "ecr_force_delete" {
  description = "Whether to force delete the ECR repository if it still contains images"
  type        = bool
  default     = false
}

variable "container_name" {
  description = "Container name used in the task definition"
  type        = string
  default     = "app"
}

variable "container_image_tag" {
  description = "Initial image tag referenced by the task definition"
  type        = string
  default     = "bootstrap"
}

variable "task_cpu" {
  description = "Task CPU units for Fargate"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Task memory in MiB for Fargate"
  type        = number
  default     = 512
}

variable "container_environment" {
  description = "Environment variables passed into the container"
  type        = map(string)
  default     = {}
}

variable "service_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for the service"
  type        = bool
  default     = false
}

variable "health_check_grace_period_seconds" {
  description = "Grace period before ALB health checks affect ECS service stability"
  type        = number
  default     = 60
}