locals {
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))

  alias       = local.global_vars.locals.alias
  environment = local.environment_vars.locals.environment
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.19.0"
    }
  }
}

provider "digitalocean" {}
EOF
}

remote_state {
  backend = "s3"
  config = {
    endpoint                    = "https://${local.region_vars.locals.region_name}.digitaloceanspaces.com"
    key                         = "${path_relative_to_include()}/terraform.tfstate"
    bucket                      = "gimadiev"
    region                      = local.region_vars.locals.region
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

inputs = merge(
  local.region_vars.locals,
  local.environment_vars.locals,
  local.global_vars.locals,
)
