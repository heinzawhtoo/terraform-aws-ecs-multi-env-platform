# dev environment

## Purpose

This folder is the Terraform root for the **dev** environment.

It composes the shared modules under `terraform/modules` to build the current Phase 3 platform foundation for development and testing. At the current stage, that includes:

- VPC
- public and private subnets
- security groups
- CloudWatch log group
- ECS cluster
- Application Load Balancer (ALB)

This environment is intended for iteration, validation, and lower-risk infrastructure changes.

---

## Current Scope

The dev environment currently provisions the base AWS platform only.

### Implemented

- VPC and subnet layout
- Internet gateway
- Optional NAT gateway behavior controlled by `enable_nat_gateway`
- ALB and target group
- ECS cluster
- CloudWatch log group
- ALB and ECS task security groups

### Not implemented yet

- ECS service
- ECS task definition
- ECR-based image workflow
- HTTPS / ACM
- autoscaling
- full application deployment pipeline

---

## Key Files

- `main.tf` — wires together the shared Terraform modules for the dev environment
- `variables.tf` — defines the inputs used by this environment
- `outputs.tf` — exposes useful infrastructure outputs such as VPC, ALB, and ECS cluster details
- `backend.tf` — configures the remote backend for dev state
- `dev.tfvars` — contains the concrete input values for the dev environment

---

## Important Local Decisions

### ALB naming

ALB-related resources use a short configurable prefix through alb_name_prefix instead of the full project name.

This exists because AWS load balancer and target group names have strict length limits.

---

## Commands

Run these commands from this folder.

### Plan

```bash 
terraform init
terraform fmt -check
terraform validate
terraform plan -var-file="dev.tfvars"
```

### Apply

```bash
terraform apply -var-file="dev.tfvars"
```

### Destroy

```bash
terraform destroy -var-file="dev.tfvars"
```
---

## What to Edit Here

Edit files in this folder when you want to change dev-specific values, such as:

- CIDR ranges
- availability zones
- app port
- ALB ingress CIDRs
- log retention
- container insights setting
- NAT behavior
- ALB short name prefix

If you want to change shared infrastructure logic used by both dev and prod, edit the appropriate module under `terraform/modules` instead.

---

## Outputs You Get

This environment exposes outputs including:

- VPC ID and CIDR
- public and private subnet IDs
- ALB security group ID
- ECS tasks security group ID
- ECS cluster name and ARN
- ALB ARN and DNS name
- target group ARN
- HTTP listener ARN

---

## Relationship to Prod

The dev environment is intentionally close to prod in structure, but not identical.

Current important difference:

- dev has NAT disabled for cost control
- prod keeps a more production-like posture

This tradeoff is deliberate and documented so the repo stays honest about its current behavior.