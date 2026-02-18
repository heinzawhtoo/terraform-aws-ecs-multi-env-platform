variable "region" { type = string }
variable "cluster_id" { type = string }
variable "service_name" { type = string }
variable "task_family" { type = string }
variable "container_name" { type = string }
variable "container_image" { type = string }
variable "container_port" {
  type    = number
  default = 80
}
variable "cpu" { type = number }
variable "memory" { type = number }
variable "desired_count" { type = number }

variable "minimum_healthy_percent" {
  type    = number
  default = 100
}

variable "maximum_percent" {
  type    = number
  default = 200
}

variable "execution_role_arn" { type = string }
variable "task_role_arn" { type = string }
variable "log_group_name" { type = string }

variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "target_group_arn" { type = string }
variable "alb_security_group_id" { type = string }

variable "tags" {
  type    = map(string)
  default = {}
}
