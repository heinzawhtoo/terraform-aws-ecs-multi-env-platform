variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Map of AZ => public subnet CIDR"
  type        = map(string)
}

variable "private_subnet_cidrs" {
  description = "Map of AZ => private subnet CIDR"
  type        = map(string)
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
