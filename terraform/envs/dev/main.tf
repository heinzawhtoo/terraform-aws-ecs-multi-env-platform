module "platform" {
  source = "../../modules/platform"

  project_name = local.project_name
  environment  = local.environment
}