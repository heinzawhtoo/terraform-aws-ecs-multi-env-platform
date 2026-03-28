# terraform bootstrap

This folder contains the **bootstrap Terraform roots** for the project.

These roots are different from `terraform/envs/dev` and `terraform/envs/prod` because they build the **control plane** for the rest of the repo.

---

## What lives here

### `backend/`
Creates the persistent S3 bucket used for Terraform remote state.

### `oidc/`
Creates the GitHub Actions OIDC provider and a small test role/policy used to validate GitHub-to-AWS authentication.

### `terraform-ci-roles/`
Creates the IAM roles used by GitHub Actions Terraform CI for **dev** and **prod**, including access to the backend bucket and permissions needed for the project infrastructure.

---

## Why this is separate

Bootstrap resources are foundational.

They should not be mixed into the environment roots because that creates ugly dependency loops like:
- CI needs roles before it can run Terraform
- Terraform needs backend before it can use remote state
- environments need bootstrap in place before they are safe to use in CI

Keeping bootstrap separate avoids that nonsense.

---

## Recommended order

In a fresh AWS account, run bootstrap in this order:

```bash
cd terraform/bootstrap/oidc
terraform init
terraform plan
terraform apply
```

```bash
cd ../backend
terraform init
terraform plan -var="bucket_name=YOUR_TF_STATE_BUCKET"
terraform apply -var="bucket_name=YOUR_TF_STATE_BUCKET"
```

```bash
cd ../terraform-ci-roles
terraform init
terraform plan -var="tf_state_bucket_name=YOUR_TF_STATE_BUCKET"
terraform apply -var="tf_state_bucket_name=YOUR_TF_STATE_BUCKET"
```

Then move on to:
- `terraform/envs/dev`
- `terraform/envs/prod`

---

## Important cautions

- These folders affect the account control plane
- Bad changes here can break GitHub Actions authentication
- Bad changes here can break Terraform remote state access
- Bad changes here can break both dev and prod CI in one shot

Treat bootstrap changes with more care than normal environment tuning.

---

## What does **not** belong here

Do **not** edit bootstrap for:
- subnet CIDRs
- app port
- ALB ingress rules
- service desired count
- environment-specific tuning

That belongs under:
- `terraform/envs/dev`
- `terraform/envs/prod`

---

## State behavior

These bootstrap roots are intentionally separate from the environment backends.

In practice:
- `backend/` creates the persistent S3 bucket
- `envs/dev` and `envs/prod` use that bucket for remote state
- `terraform-ci-roles/` grants CI access to that bucket
- `oidc/` enables GitHub Actions to assume AWS roles securely

That layering is the whole point.
