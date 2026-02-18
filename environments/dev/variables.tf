variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
}

variable "project_name" {
  type    = string
  default = "app"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "prod_state_path" {
  type    = string
  default = "../prod/terraform.tfstate"
}
