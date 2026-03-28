# terraform-aws-ecs-multi-env-platform

A practical Terraform + GitHub Actions + AWS showcase project for building a multi-environment ECS platform with separate **dev** and **prod** environments.

> Current repo state: **Phase 4 is implemented in the repository and runtime validation is in progress.**
>
> The repo now contains:
> - Terraform for the shared AWS platform foundation
> - Terraform for ECS application infrastructure
> - GitHub Actions Terraform CI for **dev** and **prod**
> - GitHub Actions application build / push / deploy workflows for **dev** and **prod**

---

## What this repository currently contains

### Infrastructure and platform
- GitHub Actions OIDC authentication for AWS
- Separate Terraform CI roles for **dev** and **prod**
- Separate GitHub Actions app delivery roles for **dev** and **prod**
- Remote Terraform state in S3
- Separate Terraform roots for **dev** and **prod**
- Reusable Terraform modules

### AWS resources currently modeled in Terraform
- VPC
- Public and private subnets
- Optional NAT gateway
- Security groups
- CloudWatch log group
- ECS cluster
- Application Load Balancer
- ECR repository
- ECS task execution role
- ECS task definition
- ECS service

### Application code
- A small FastAPI sample app under `app/`
- A Dockerfile for containerizing the sample app

### CI/CD workflows
- Terraform format / validate / plan workflow for **dev** and **prod**
- Dev application build / push / deploy workflow
- Prod application build / push / deploy workflow

---

## What Phase 4 covers

Phase 4 in this repo means the platform can now do the full app delivery path:

1. provision AWS infrastructure with Terraform
2. build the sample app container image
3. push the image to Amazon ECR
4. trigger ECS service deployment from GitHub Actions
5. wait for ECS service stability after rollout

One important design choice: **Terraform owns service scaling**, while the app workflows handle **build, push, and rollout**. The app deploy workflows do not change ECS desired count.

---

## What is still not finished yet

This repo is **not** pretending to be a fully hardened production platform yet.

Things that still belong in later phases:
- tighter least-privilege scoping for app deploy permissions
- task-definition rendering or explicit image tag promotion workflows
- approvals / protected environments for prod promotion
- deeper observability, alarms, dashboards, and runbooks
- secrets management for real application configuration
- custom domain / TLS / Route 53 integration if desired

That is normal. Good infrastructure is layered, not imagined into existence.

---

## Repository structure

```text
.
├── .github/
│   └── workflows/
│       ├── app-build-dev.yml
│       ├── app-build-prod.yml
│       └── terraform-ci.yml
├── app/
│   ├── app.py
│   ├── Dockerfile
│   └── requirements.txt
├── terraform/
│   ├── bootstrap/
│   │   ├── backend/
│   │   ├── oidc/
│   │   ├── terraform-ci-roles/
│   │   └── README.md
│   ├── envs/
│   │   ├── dev/
│   │   └── prod/
│   └── modules/
│       ├── alb/
│       ├── cloudwatch_logs/
│       ├── ecr/
│       ├── ecs_cluster/
│       ├── ecs_service/
│       ├── ecs_task_definition/
│       ├── ecs_task_execution_role/
│       ├── platform/
│       ├── security_groups/
│       └── vpc/
└── README.md
```

---

## Bootstrap vs environment roots

This repo uses multiple Terraform roots on purpose.

### Bootstrap roots
Run these only for account-level control-plane setup:

- `terraform/bootstrap/oidc`
- `terraform/bootstrap/backend`
- `terraform/bootstrap/terraform-ci-roles`

### Environment roots
Run these for environment infrastructure and ECS resources:

- `terraform/envs/dev`
- `terraform/envs/prod`

### Do not run Terraform from
- the repo root
- `terraform/`
- `terraform/modules/*`

Those are not deployable roots.

---

## Recommended execution order in a fresh AWS account

When standing up this repo in a new AWS account, use this order:

1. `terraform/bootstrap/oidc`
2. `terraform/bootstrap/backend`
3. `terraform/bootstrap/terraform-ci-roles`
4. `terraform/envs/dev`
5. `terraform/envs/prod`

If you already have a GitHub OIDC provider in the account, import it instead of trying to create a duplicate one.

---

## Backend behavior

The environment backend configuration is intentionally split so the repo does **not** hard-code an AWS account-specific S3 bucket name inside `backend.tf`.

That means local usage should provide the bucket name at init time.

Example for **dev**:

```bash
cd terraform/envs/dev
terraform init -reconfigure \
  -backend-config="bucket=YOUR_TF_STATE_BUCKET" \
  -backend-config="region=YOUR_AWS_REGION"
terraform plan -var-file="dev.tfvars"
```

Example for **prod**:

```bash
cd terraform/envs/prod
terraform init -reconfigure \
  -backend-config="bucket=YOUR_TF_STATE_BUCKET" \
  -backend-config="region=YOUR_AWS_REGION"
terraform plan -var-file="prod.tfvars"
```

If you prefer, you can also supply the bucket through a local `.tfbackend` file that stays out of version control.

---

## Current CI/CD state

### Terraform CI
The committed workflow in `.github/workflows/terraform-ci.yml` handles Terraform CI for **dev** and **prod**:

- AWS credential setup through OIDC
- `terraform init`
- `terraform fmt -check`
- `terraform validate`
- `terraform plan`

### App delivery workflows
The committed application workflows handle:

- Docker image build
- Amazon ECR login
- image push to ECR
- ECS service forced deployment
- wait for ECS service stability

Current workflow files:
- `.github/workflows/app-build-dev.yml`
- `.github/workflows/app-build-prod.yml`

---

## GitHub Actions CI/CD configuration

This repo uses GitHub OIDC plus repository variables.

### Required GitHub repository variables

Set these under:

`Settings -> Secrets and variables -> Actions -> Variables`

Required variables:

- `AWS_REGION`
  Example: `ap-southeast-1`

- `TF_STATE_BUCKET_NAME`
  Example: `heinzawhtoo-tf-state-091234567891-apse1`

- `AWS_TERRAFORM_DEV_ROLE_ARN`
  ARN of the dev Terraform CI role created by `terraform/bootstrap/terraform-ci-roles`

- `AWS_TERRAFORM_PROD_ROLE_ARN`
  ARN of the prod Terraform CI role created by `terraform/bootstrap/terraform-ci-roles`

- `AWS_APP_DEV_ROLE_ARN`
  ARN of the dev app build/deploy role created by `terraform/bootstrap/terraform-ci-roles`

- `AWS_APP_PROD_ROLE_ARN`
  ARN of the prod app build/deploy role created by `terraform/bootstrap/terraform-ci-roles`

### Why the workflow injects backend config

The environment roots keep a backend skeleton in `backend.tf`, but the CI workflow injects the backend bucket during `terraform init`:

```bash
terraform init -input=false -reconfigure \
  -backend-config="bucket=${TF_STATE_BUCKET_NAME}" \
  -backend-config="region=${AWS_REGION}"
```

This avoids hard-coding account-specific backend values into workflow logic and makes account migration much cleaner.

### Local vs CI behavior

- Local runs may still use backend config files or direct `-backend-config`
- CI does not rely on local developer files
- CI always uses the GitHub repository variables above

---

## Environments

### Dev
Use dev for:
- iteration
- testing
- low-risk infrastructure changes
- cheaper experimentation

### Prod
Use prod for:
- production-style separation
- stricter review
- closer-to-real-world settings

Each environment has its own:
- Terraform root
- state key
- tfvars file
- IAM role used by Terraform CI
- IAM role used by app delivery workflows

---

## App folder

The `app/` directory contains a small FastAPI app used as the sample ECS workload for this project.

It is intentionally simple:
- `/health` returns health and environment info
- `/api/cidr` calculates CIDR details
- `/` serves a tiny HTML UI

This keeps the repo focused on platform delivery while still having a real container target.

---

## Practical day-to-day commands

### Bootstrap IAM roles
```bash
cd terraform/bootstrap/terraform-ci-roles
terraform init
terraform fmt
terraform validate
terraform plan -var="tf_state_bucket_name=YOUR_TF_STATE_BUCKET"
terraform apply -var="tf_state_bucket_name=YOUR_TF_STATE_BUCKET"
```

### Dev
```bash
cd terraform/envs/dev
terraform init -reconfigure \
  -backend-config="bucket=YOUR_TF_STATE_BUCKET" \
  -backend-config="region=YOUR_AWS_REGION"
terraform fmt -check
terraform validate
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

Destroy:
```bash
terraform destroy -var-file="dev.tfvars"
```

### Prod
```bash
cd terraform/envs/prod
terraform init -reconfigure \
  -backend-config="bucket=YOUR_TF_STATE_BUCKET" \
  -backend-config="region=YOUR_AWS_REGION"
terraform fmt -check
terraform validate
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
```

Destroy:
```bash
terraform destroy -var-file="prod.tfvars"
```

---

## How deployments work right now

### Dev
- push to `main` with changes under `app/**`
- GitHub Actions builds the container
- GitHub Actions pushes the image to the dev ECR repository
- GitHub Actions runs `aws ecs update-service --force-new-deployment`
- GitHub Actions waits for the ECS service to become stable

### Prod
- run the prod workflow manually
- build and push the prod image
- trigger ECS rollout
- wait for service stability

This is deliberately simple and practical for a showcase project.

---

## Cost and safety guidance

- Keep the backend bucket persistent
- Keep bootstrap resources persistent unless you are intentionally rebuilding the control plane
- Destroy expensive runtime infrastructure when idle if this is still a showcase/lab environment
- Review prod plans more carefully than dev plans
- Keep prod deployment manual until later hardening phases
- Do not trust old README text after large Terraform refactors unless it has been refreshed

---

## Phase 5 direction

A strong next phase would be:

- task-definition driven deploy workflow with explicit image tag promotion
- prod approvals / protected environments
- CloudWatch alarms and autoscaling validation
- ECS Exec enablement and operational docs
- optional HTTPS / ACM / Route 53
- secrets injection through SSM Parameter Store or Secrets Manager

That is where "works" starts turning into "solid".
