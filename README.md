# terraform-aws-ecs-multi-env-platform

A practical Terraform + GitHub Actions + AWS showcase project for building a multi-environment ECS platform with separate **dev** and **prod** environments.

> Current repo state: **Phase 4 is in progress.**
>
> The repository already contains Terraform for the platform foundation **and** ECS application infrastructure (ECR, task execution role, task definition, and ECS service), but the committed GitHub Actions workflow is still focused on Terraform validation and planning only.

---

## What this repository currently contains

### Infrastructure and platform
- GitHub Actions OIDC authentication for AWS
- Separate Terraform CI roles for **dev** and **prod**
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

---

## What is not finished yet

This repo is **not** a polished end-to-end production delivery system yet.

What is still incomplete or still needs repo cleanup:
- GitHub Actions is still only running Terraform CI
- There is no committed application image build-and-push workflow yet
- There is no committed ECS application deployment workflow yet
- The backend configuration has been refactored away from an account-specific hard-coded bucket, so local and CI usage should clearly document how backend bucket values are supplied
- Some docs previously described the repo as “Phase 3 only”; that is no longer accurate

That is fine. Honest repos age better than fake-finished repos.

---

## Repository structure

```text
.
├── .github/
│   └── workflows/
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

If you already have a GitHub OIDC provider in the account, import it instead of blindly trying to create a duplicate one.

---

## Backend behavior

The environment backend configuration is intentionally split so the repo does **not** hard-code an AWS account specific S3 bucket name inside `backend.tf`.

That means local usage should provide the bucket name at init time.

Example for **dev**:

```bash
cd terraform/envs/dev
terraform init -reconfigure -backend-config="bucket=YOUR_TF_STATE_BUCKET"
terraform plan -var-file="dev.tfvars"
```

Example for **prod**:

```bash
cd terraform/envs/prod
terraform init -reconfigure -backend-config="bucket=YOUR_TF_STATE_BUCKET"
terraform plan -var-file="prod.tfvars"
```

If you prefer, you can also supply the bucket through a local `.tfbackend` file that is kept out of version control.

---

## Current CI/CD state

The committed workflow in `.github/workflows/terraform-ci.yml` currently handles Terraform CI for **dev** and **prod**:
- AWS credential setup through OIDC
- `terraform init`
- `terraform fmt -check`
- `terraform validate`
- `terraform plan`

That workflow still needs to be aligned with the partial backend configuration approach if the backend bucket is no longer hard-coded.

---

## GitHub Actions CI configuration

The Terraform CI workflow uses GitHub OIDC plus repository variables.

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

### Why the workflow injects backend config

The environment roots keep a backend skeleton in `backend.tf`, but the CI workflow injects the backend bucket during `terraform init`:

```bash
terraform init -input=false -reconfigure \
  -backend-config="bucket=${TF_STATE_BUCKET_NAME}" \
  -backend-config="region=${AWS_REGION}"
```
This avoids hard-coding account-specific backend values into the workflow logic and keeps account migration cleaner

### Local vs CI behavior

- Local runs may still use backend.s3.tfbackend
- CI does not rely on local developer files for backend bucket selection
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
- IAM role used by CI

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

### Dev
```bash
cd terraform/envs/dev
terraform init -reconfigure -backend-config="bucket=YOUR_TF_STATE_BUCKET"
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
terraform init -reconfigure -backend-config="bucket=YOUR_TF_STATE_BUCKET"
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

## Cost and safety guidance

- Keep the backend bucket persistent
- Keep bootstrap resources persistent unless you are intentionally rebuilding the control plane
- Destroy expensive runtime infrastructure when idle if this is still a showcase/lab environment
- Review prod plans more carefully than dev plans
- Do not trust old README text after large Terraform refactors unless it has been refreshed

