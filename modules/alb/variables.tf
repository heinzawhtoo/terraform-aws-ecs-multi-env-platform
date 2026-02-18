variable "name_prefix" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" {
  type    = list(string)
  default = []
}

variable "target_group_name" { type = string }
variable "target_group_port" {
  type    = number
  default = 80
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "create_alb" {
  type    = bool
  default = true
}

variable "create_listener" {
  type    = bool
  default = false
}

variable "create_path_rule" {
  type    = bool
  default = false
}

variable "path_patterns" {
  type    = list(string)
  default = ["/*"]
}

variable "path_rule_priority" {
  type    = number
  default = 100
}

variable "existing_alb_arn" {
  type    = string
  default = null
}

variable "existing_alb_dns_name" {
  type    = string
  default = null
}

variable "existing_alb_zone_id" {
  type    = string
  default = null
}

variable "existing_alb_security_group_id" {
  type    = string
  default = null
}

variable "existing_listener_arn" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
