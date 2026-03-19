terraform {
  backend "s3" {
    bucket       = "heinzawhtoo-tf-state-066506852481-apse1"
    key          = "envs/prod/terraform.tfstate"
    region       = "ap-southeast-1"
    use_lockfile = true
  }
}