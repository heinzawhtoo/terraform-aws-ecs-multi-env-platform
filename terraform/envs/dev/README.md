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
- `dev.tfvars.example` - Example variable values for local setup
- `dev.tfvars` - Real local variable file used for execution (not recommended to commit)

## Variable Strategy

This root module uses:

- **input variables** for environment-specific values
- **locals** only for derived values

This keeps the root module reusable and closer to real-world Terraform practice.

## Local Setup

1. Copy the example file:

```bash
cp dev.tfvars.example dev.tfvars