locals {
  global = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  env    = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  region = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "${dirname(find_in_parent_folders())}/../modules/kubernetes"
}

inputs = {
  name   = "${local.global.locals.alias}-${local.env.locals.environment}"
  region = local.region.locals.region_name
}
