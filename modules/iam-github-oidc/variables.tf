variable "github_org" { type = string }
variable "github_repo" { type = string }
variable "allowed_branches" {
  type    = list(string)
  default = ["dev", "main"]
}

variable "role_name" { type = string }

variable "passrole_arns" {
  type    = list(string)
  default = ["*"]
}

variable "tags" {
  type    = map(string)
  default = {}
}
