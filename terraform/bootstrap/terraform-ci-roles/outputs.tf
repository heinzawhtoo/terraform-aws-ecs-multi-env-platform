output "terraform_dev_role_arn" {
  description = "IAM role ARN for Terraform dev CI"
  value       = aws_iam_role.terraform_dev.arn
}

output "terraform_prod_role_arn" {
  description = "IAM role ARN for Terraform prod CI"
  value       = aws_iam_role.terraform_prod.arn
}