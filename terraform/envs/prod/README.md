# Prod Environment - Phase 3 Platform Foundation

This directory defines the **prod** root Terraform configuration for the project:

- **Project:** `terraform-aws-ecs-multi-env-platform`
- **Environment:** `prod`
- **Phase:** `3A to 3D - platform foundation`

## Resources provisioned

This root module provisions the base AWS platform for the prod environment:

- VPC
- 2 public subnets
- 2 private subnets
- Internet Gateway
- NAT Gateway
- ALB security group
- ECS tasks security group
- CloudWatch log group
- ECS cluster
- Application Load Balancer
- Target group
- HTTP listener

## File overview

- `backend.tf` - Remote state backend
- `providers.tf` - Terraform and provider configuration
- `variables.tf` - Root input variables
- `locals.tf` - Derived values and common tags
- `main.tf` - Root module wiring
- `outputs.tf` - Outputs for later phases
- `prod.tfvars` - Environment values used locally and in CI
- `prod.tfvars.example` - Reference copy of environment values

## Variable strategy

This root module uses:

- **input variables** for environment-specific values
- **locals** only for derived values such as shared tags

For this showcase project, non-sensitive environment `.tfvars` files are committed so that:

- local runs are simple
- CI runs are reproducible
- repo reviewers can understand the root module inputs easily

Secrets must not be stored in `.tfvars` files.

## Commands

```powershell
terraform fmt -recursive
terraform init
terraform validate
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars" -auto-approve