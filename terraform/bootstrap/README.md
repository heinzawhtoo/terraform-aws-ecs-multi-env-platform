# terraform-ci-roles bootstrap

## Purpose

This folder contains the Terraform configuration used to bootstrap the IAM and OIDC setup required for GitHub Actions to run Terraform against AWS.

This is **bootstrap/control-plane setup**, not day-to-day environment infrastructure.

---

## What This Folder Creates

This bootstrap configuration is responsible for setting up:

- trust relationship with the existing GitHub OIDC provider
- IAM role for Terraform CI in **dev**
- IAM role for Terraform CI in **prod**
- backend access permissions for the S3 Terraform state bucket
- permissions needed to manage the current platform resources used by this project

That includes permissions related to:

- VPC and subnet resources
- security groups
- load balancer resources
- ECS cluster and future ECS service operations
- CloudWatch Logs
- ECR-related operations
- application autoscaling-related operations
- selected IAM role management for project-scoped roles

---

## Why This Is Separate

This folder is separated from `terraform/envs/*` on purpose.

Reason:

- bootstrap IAM/OIDC setup should not be mixed with day-to-day platform infrastructure
- CI role creation is foundational
- the env roots should assume the CI roles already exist

This separation keeps the project cleaner and reduces the chance of circular setup problems.

---

## When to Edit This Folder

Edit this folder when you need to change:

- GitHub org / repo / branch trust conditions
- CI role names
- AWS permissions granted to Terraform CI
- backend bucket access policy scope
- new permissions required by later project phases

Do **not** edit this folder for normal environment tuning such as subnet CIDRs or ALB ingress rules. That belongs in `terraform/envs/dev` or `terraform/envs/prod`.

---

## Operational Caution

Changes in this folder affect the CI control plane.

That means a bad change here can break:

- GitHub Actions authentication
- Terraform plan/apply in CI
- access to remote state
- future platform deployments

Treat changes here more carefully than ordinary module changes.

---

## Relationship to the Rest of the Repo

- `bootstrap/terraform-ci-roles` sets up CI access
- `envs/dev` and `envs/prod` use that access to manage infrastructure
- `modules/*` contain the reusable infrastructure logic

That is the intended layering.

---

## Current Phase Context

At the current project stage, this bootstrap supports the Phase 3 platform foundation and also includes permissions that anticipate later phases such as:

- ECS service operations
- ECR repository operations
- application autoscaling operations
- project-scoped IAM role management for ECS-related roles

That is acceptable as long as the permissions remain intentional and reviewed.