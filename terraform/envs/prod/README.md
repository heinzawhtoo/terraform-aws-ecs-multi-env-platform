# prod environment

## Purpose

This folder is the Terraform root for the **prod** environment.

It composes the shared modules under `terraform/modules` to build the current Phase 3 production-style platform foundation. At the current stage, that includes:

- VPC
- public and private subnets
- security groups
- CloudWatch log group
- ECS cluster
- Application Load Balancer (ALB)

This environment is intended to stay closer to a real production layout than dev.

---

## Current Scope

The prod environment currently provisions the base AWS platform only.

### Implemented

- VPC and subnet layout
- Internet gateway
- NAT gateway support
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

- `main.tf` — wires together the shared Terraform modules for the prod environment
- `variables.tf` — defines the inputs used by this environment
- `outputs.tf` — exposes useful infrastructure outputs such as VPC, ALB, and ECS cluster details
- `backend.tf` — configures the remote backend for prod state
- `prod.tfvars` — contains the concrete input values for the prod environment

---

## Important Local Decisions

### Production-style posture

Prod is intended to remain closer to a realistic production baseline than dev.

That means prod should be treated more carefully when changing:

- network settings
- ingress ranges
- ALB behavior
- naming
- future service deployment settings

### ALB naming

ALB-related resources use a short configurable prefix through `alb_name_prefix` instead of the full project name.

This exists because AWS load balancer and target group names have strict length limits.

---

## Commands

Run these commands from this folder.

### Plan

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan -var-file="prod.tfvars"
```

### Apply

```bash
terraform apply -var-file="prod.tfvars"
```

### Destroy

```bash
terraform destroy -var-file="prod.tfvars"
```
---

## What to Edit Here

Edit files in this folder when you want to change prod-specific values, such as:

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

## Safety Notes

Treat prod changes more carefully than dev changes.

Recommended practice:

1. plan locally first
2. review the diff carefully
3. apply dev first when the change affects shared modules
4. apply prod only after the change is understood

At the current stage, prod is still Phase 3 platform infrastructure — not a complete production-ready ECS application stack.