# Dev Environment - Phase 3A VPC Foundation

This directory defines the **dev** root Terraform configuration for the project:

- **Project:** `terraform-aws-ecs-multi-env-platform`
- **Environment:** `dev`
- **Phase:** `3A - VPC Foundation`

## Purpose

This root module provisions the foundational AWS networking layer for the dev environment:

- 1 VPC
- 2 public subnets across 2 Availability Zones
- 2 private subnets across 2 Availability Zones
- 1 Internet Gateway
- 1 NAT Gateway
- Public and private route tables

This layout is intended to support a later ECS on Fargate deployment, where:

- the **Application Load Balancer** will sit in public subnets
- the **ECS tasks** will run in private subnets

## Files

- `backend.tf` - Remote state backend configuration
- `providers.tf` - Terraform version, provider version, and AWS provider configuration
- `variables.tf` - Root module input variables
- `locals.tf` - Derived values such as common tags
- `main.tf` - Root module wiring for the VPC module
- `outputs.tf` - Outputs used by later phases
- `dev.tfvars` - Environment-specific input values for the dev root module
- `dev.tfvars.example` - Example variable file for reference

## Variable Strategy

This root module uses:

- **input variables** for environment-specific values
- **locals** only for derived values

For this showcase project, non-sensitive environment `.tfvars` files are committed to the repository so that:

- local execution is simple
- GitHub Actions can run Terraform consistently
- reviewers can reproduce plans more easily

Secrets must **not** be stored in `.tfvars` files.

## Local Setup

1. Initialize Terraform:

```bash
terraform init