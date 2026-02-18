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
  default = "prod"
}

variable "github_org" {
  type = string
}

variable "github_repo" {
  type = string
}
