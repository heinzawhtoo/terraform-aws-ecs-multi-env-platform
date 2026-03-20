# terraform-aws-ecs-multi-env-platform

A phased **Terraform + GitHub Actions + AWS** showcase project for building a **multi-environment ECS platform** with separate **dev** and **prod** infrastructure.

> **Current status:** Phase 3 base platform infrastructure is complete.  
> This repository currently provides the **Terraform foundation, CI workflow, remote state setup, and core AWS platform resources** needed for later ECS application deployment.

---

## Overview

This project is a practical, step-by-step build of an AWS platform using:

- **Terraform** for infrastructure as code
- **GitHub Actions** for CI
- **AWS OIDC** for secure GitHub-to-AWS authentication
- Separate **dev** and **prod** environments
- Reusable Terraform **modules**
- Remote Terraform state in **S3**

The goal is to build a clean, realistic platform foundation first, then layer in application deployment, hardening, and operational improvements in later phases.

---

## Current Scope

### Implemented

This repository currently includes:

- AWS OIDC setup for GitHub Actions
- Separate Terraform CI roles for **dev** and **prod**
- Remote Terraform state stored in **S3**
- Environment-specific Terraform roots
- Reusable Terraform modules
- Base AWS platform infrastructure for both environments:
  - VPC
  - Public and private subnets
  - NAT gateway support
  - Security groups
  - ECS cluster
  - CloudWatch log group
  - Application Load Balancer (ALB)

### Planned Next

The following are **not yet implemented** in the current public state of the repository:

- ECR repository and image workflow
- ECS task definition
- ECS service
- Application deployment pipeline
- Path-based routing
- Auto scaling
- HTTPS with ACM
- Additional production hardening and ops improvements

This is intentional. The repo is being built in phases rather than pretending to be complete before the platform actually is.

---

## Project Roadmap

The platform is being built in the following stages:

- **Phase 1** — AWS OIDC bootstrap
- **Phase 2** — Terraform CI and remote backend
- **Phase 3** — Base AWS platform infrastructure
- **Phase 4** — ECS service, ECR, and deployment pipeline
- **Phase 5** — Hardening, HTTPS, scaling, and operations polish

At the current stage, the most accurate description of this repo is:

> **A multi-environment AWS platform foundation for future ECS application deployment**

---

## Repository Structure

```text
.
├── .github/
│   └── workflows/
│       └── terraform-ci.yml
├── terraform/
│   ├── bootstrap/
│   │   └── terraform-ci-roles/
│   ├── envs/
│   │   ├── dev/
│   │   │   ├── backend.tf
│   │   │   ├── dev.tfvars
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   └── prod/
│   │       ├── backend.tf
│   │       ├── main.tf
│   │       ├── outputs.tf
│   │       ├── prod.tfvars
│   │       └── variables.tf
│   └── modules/
│       ├── alb/
│       ├── cloudwatch_logs/
│       ├── ecs_cluster/
│       ├── security_groups/
│       └── vpc/
├── .gitignore
└── LICENSE 
```

---

## Environments
This project uses two isolated Terraform environments:

- **dev** — used for testing, iteration, and lower-risk changes
- **prod** — used for production-style separation and stricter environment boundaries

Each environment has its own:

- Terraform root configuration
- `.tfvars` file
- backend state key
- GitHub Actions AWS role

This keeps state, plan output, and environment behavior clearly separated.

---

## CI/CD Approach

GitHub Actions is used to run Terraform validation and planning for both environments.

### Current CI responsibilities

For each environment, CI runs:

- `terraform fmt -check`
- `terraform init`
- `terraform validate`
- `terraform plan`

This gives a clean early warning system for formatting issues, configuration errors, and infrastructure changes before manual apply.

### Authentication model

This repository uses GitHub Actions OIDC to assume AWS IAM roles.

That means:

- no long-lived AWS access keys stored in GitHub secrets
- separate AWS roles for dev and prod
- cleaner and safer CI authentication

That is the right direction. Static cloud credentials in CI are a bad habit and worth avoiding.

---

## Terraform Backend

Terraform state is stored remotely in S3.

### Backend design

- Shared persistent S3 backend
- Separate state keys for dev and prod
- S3 lockfile-based locking
- No DynamoDB lock table

The backend bucket is intended to remain persistent even when environment infrastructure is destroyed.

That separation matters because backend state storage is foundational, while environment resources are disposable.

---

## Prerequisites

Before using this repository, make sure you have:

- Terraform installed
- An AWS account
- AWS IAM roles configured for GitHub OIDC
- An S3 bucket for Terraform remote state
- GitHub Actions variables/secrets configured where required
- Appropriate AWS permissions for local Terraform use

Recommended tools:

- AWS CLI

- Git

- A separate AWS sandbox or careful IAM isolation for experimentation

---

## Local Usage
### Dev

```bash
cd terraform/envs/dev
terraform init
terraform fmt -check
terraform validate
terraform plan -var-file="dev.tfvars"
```
Apply:

```bash
terraform apply -var-file="dev.tfvars"
```
Destroy:

```bash
terraform destroy -var-file="dev.tfvars"
```

### Prod

```bash
cd terraform/envs/prod
terraform init
terraform fmt -check
terraform validate
terraform plan -var-file="prod.tfvars"
```
Apply:

```bash
terraform apply -var-file="prod.tfvars"
```

Destroy:

```bash
terraform destroy -var-file="prod.tfvars"
```


---
---

## Operational Guidance
### What should stay persistent

Keep the Terraform backend S3 bucket persistent.

That bucket is part of your control plane and should not be treated like disposable runtime infrastructure.

### What can be destroyed

You can destroy dev and prod infrastructure when not in use, especially during early phases.

That is often the smartest move for cost control in a lab or showcase project.

### Practical rule

Destroy expensive runtime infrastructure when idle.
Do not destroy the remote backend unless you are intentionally tearing down the entire project.

---

## Cost Notes
This repository is built to reflect a realistic AWS platform structure, not a free-tier-only toy setup.

### Important cost drivers

The main cost drivers in the current and upcoming phases are:

- NAT Gateway
- Application Load Balancer
- Elastic IP
- CloudWatch Logs
- ECS-related resources added in later phases

### Practical cost advice

- Keep the backend bucket persistent
- Destroy environment infrastructure when you are not actively using it
- Do not leave NAT gateways and ALBs running for no reason
- Treat prod as optional until the application deployment phase if cost matters

AWS is very good at charging rent for resources that sit there quietly doing nothing. That part is unfortunately world-class.

### Dev NAT strategy

The `dev` environment has `enable_nat_gateway = false` to reduce idle AWS cost during the current infrastructure phase.

This means:

- dev private subnets do not have outbound internet access through a NAT gateway
- dev is intentionally more cost-optimized than prod at this stage
- this tradeoff is acceptable for the current base platform phase
- NAT can be re-enabled later when ECS service deployment or other private-subnet egress requirements make it necessary

This is a deliberate cost-control decision, not an accident.

---

## Security Notes

The current Phase 3 setup favors momentum and platform progress over final production hardening.

### Current tradeoffs

At this stage, the platform is intentionally simplified:

- ALB behavior is still basic
- HTTP may still be used during this phase
- Ingress may be broader than the final desired posture
- Security hardening is still incomplete

### Planned hardening

Upcoming improvements are expected to include:

- HTTPS with ACM
- tighter ingress controls
- improved separation of public and private exposure
- stricter IAM permissions for ECS workloads
- more production-grade deployment and runtime controls

This is deliberate. The platform is being built in the correct order:

**foundation first, then deployment, then hardening and polish**

### Dev vs prod networking tradeoff

To keep costs under control during early platform build-out:

- `prod` retains a more production-like network posture
- `dev` may use a reduced-cost setup, including NAT being disabled

This improves cost efficiency during the current phase, but it also means dev and prod are not fully identical in outbound private-subnet behavior.

---

## Current Terraform Modules
`vpc`

Creates the base networking layer, including:

- VPC
- public subnets
- private subnets
- internet gateway
- optional NAT gateway
- route tables

`security_groups`

Creates security groups for:

- ALB access
- ECS-related traffic flow
- internal connectivity patterns

`cloudwatch_logs`

Creates CloudWatch log groups for platform and application logging.

`ecs_cluster`

Creates the ECS cluster that will later host workloads and services.

`alb`

Creates the Application Load Balancer foundation, including:

- ALB
- listener
- target group

This is currently platform groundwork, not yet a complete app-routing solution.

---

## Design Principles

This project follows a few simple rules:

- **Separate environments clearly**
- **Reuse modules instead of copy-pasting infrastructure**
- **Use OIDC instead of static AWS credentials**
- **Keep backend state persistent**
- **Destroy expensive runtime infrastructure when idle**
- **Build in phases instead of pretending the whole platform already exists**
- **Keep the repo honest about what is done and what is still planned**

That last one matters more than people think. A smaller repo that tells the truth beats a flashy repo that oversells itself.

---
## Why This Repo Exists
This repository is meant to be:

- a real learning project
- a practical Terraform showcase
- a clean base for future ECS deployment work
- a phased build that can be reviewed and understood step by step

It is not trying to be a giant fake-enterprise template stuffed with unfinished promises.

That kind of repo looks impressive for five minutes and painful forever.

---

Next Planned Work

The next major phase is expected to focus on:

adding an ECR module

adding ECS task definition support

adding ECS service support

connecting ECS services to the ALB target group

creating an application deployment workflow

improving security posture

moving toward HTTPS and more production-grade behavior

That is where this foundation starts turning into a real deployable platform.

---

## Next Planned Work

The next major phase is expected to focus on:

- adding an ECR module
- adding ECS task definition support
- adding ECS service support
- connecting ECS services to the ALB target group
- creating an application deployment workflow
- improving security posture
- moving toward HTTPS and more production-grade behavior
- Reassess dev NAT requirements once ECS service deployment is added
- Introduce selective VPC endpoints later to reduce NAT dependence for AWS service access

That is where this foundation starts turning into a real deployable platform.

---

## Contributing
This is currently a personal showcase and learning project, but suggestions and improvements are welcome.

If you fork or adapt this repository:

- review all environment naming
- review security defaults carefully
- review cost-impacting resources
- avoid committing secrets

treat this as a foundation, not a finished production template

---

## Disclaimer

This repository is a learning and showcase project.

It is not yet a fully production-ready ECS deployment stack.
Use it as a foundation and reference point, not as a finished blueprint.

---

## License

This project is licensed under the terms of the license included in this repository.