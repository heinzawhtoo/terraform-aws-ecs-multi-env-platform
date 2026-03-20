# terraform modules

## Purpose

This folder contains the reusable Terraform building blocks used by the environment roots under:

- `terraform/envs/dev`
- `terraform/envs/prod`

The current project goal is to keep environment roots thin and move shared infrastructure logic into modules.

---

## Current Modules

### `vpc`

Creates the base network foundation:

- VPC
- public subnets
- private subnets
- internet gateway
- optional NAT gateway
- route tables and associations

### `security_groups`

Creates:

- ALB security group
- ECS tasks security group

### `cloudwatch_logs`

Creates the CloudWatch log group used for ECS application logging.

### `ecs_cluster`

Creates the ECS cluster and configures container insights.

### `alb`

Creates:

- Application Load Balancer
- HTTP listener
- target group

---

## Design Rule

Modules in this folder should be:

- reusable
- environment-agnostic
- focused on one responsibility
- free of hardcoded dev/prod behavior wherever possible

Environment-specific values should stay in the environment roots and `.tfvars` files.

---

## What Belongs Here

Good candidates for this folder:

- shared network modules
- shared compute modules
- shared logging modules
- shared load balancing modules
- future shared ECS service/task/ECR modules

---

## What Does Not Belong Here

Avoid putting these directly in modules unless truly necessary:

- dev-only behavior
- prod-only behavior
- backend configuration
- GitHub Actions workflow logic
- bootstrap-only IAM setup for CI roles

Those belong in the environment roots, workflow files, or bootstrap folders instead.

---

## Current Phase Context

At the current Phase 3 state, these modules provide the base AWS platform foundation.

They do **not yet** provide:

- ECS service deployment
- ECS task definitions
- ECR workflow
- autoscaling
- HTTPS / ACM integration

Those are expected to be added in later phases, likely as additional modules or extensions to the current ones.

---

## Usage Pattern

The intended pattern is:

1. define reusable logic here
2. wire modules together in `envs/dev` and `envs/prod`
3. keep per-environment values in `.tfvars`
4. expose useful outputs from the environment roots

This keeps the project easier to maintain and easier to explain.