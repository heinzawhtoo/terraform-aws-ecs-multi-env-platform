# bootstrap terraform-ci-roles

This Terraform root creates the GitHub Actions Terraform roles for **dev** and **prod**.

---

## What it does

This root is responsible for:
- looking up the existing GitHub OIDC provider
- creating the Terraform CI IAM role for **dev**
- creating the Terraform CI IAM role for **prod**
- granting backend S3 bucket access
- granting the AWS permissions needed for the current Terraform-managed infrastructure

---

## What permissions it is expected to cover

At the current repo state, CI needs permissions related to:
- VPC and subnet resources
- security groups
- load balancer resources
- ECS cluster
- ECR
- ECS task execution role management
- ECS task definition and ECS service operations
- CloudWatch Logs
- selected IAM role management for project-scoped roles
- application autoscaling-related resources where applicable

---

## Input

This root should be parameterized by the Terraform state bucket name.

Example:
```bash
terraform plan -var="tf_state_bucket_name=YOUR_TF_STATE_BUCKET"
terraform apply -var="tf_state_bucket_name=YOUR_TF_STATE_BUCKET"
```

That is better than hard-coding old account-specific S3 ARNs into policy documents.

---

## Relationship to GitHub repository variables

After applying this root, copy the resulting CI role ARNs into the repository variables used by GitHub Actions.

Expected repository variables:

- `AWS_REGION`
- `TF_STATE_BUCKET_NAME`
- `AWS_TERRAFORM_DEV_ROLE_ARN`
- `AWS_TERRAFORM_PROD_ROLE_ARN`

The Terraform CI workflow uses these variables to:

- assume the correct dev or prod IAM role
- select the correct AWS region
- inject the backend S3 bucket during `terraform init`

This keeps the workflow account-aware without hard-coding account-specific values into the workflow itself.

---

## Commands

Run from this folder:

```bash
cd terraform/bootstrap/terraform-ci-roles
terraform init
terraform fmt -check
terraform validate
terraform plan -var="tf_state_bucket_name=YOUR_TF_STATE_BUCKET"
```

Apply:
```bash
terraform apply -var="tf_state_bucket_name=YOUR_TF_STATE_BUCKET"
```

---

## Why it is separate

This root is intentionally separate from `terraform/envs/*` because:
- CI roles are control-plane resources
- environment roots should assume CI roles already exist
- mixing IAM bootstrap and application infrastructure in one root becomes messy fast

---

## Important caution

A bad change here can break:
- GitHub Actions authentication
- Terraform plan/apply in CI
- remote state access
- both environments at once

So yes, this folder deserves paranoia.

---

## Relationship to the rest of the repo

- `bootstrap/oidc` enables GitHub OIDC
- `bootstrap/backend` creates the remote state bucket
- `bootstrap/terraform-ci-roles` gives CI the right roles and permissions
- `envs/dev` and `envs/prod` use those roles to manage infrastructure
