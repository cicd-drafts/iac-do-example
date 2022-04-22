locals {
  global = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  env    = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  region = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  # secrets = yamldecode(sops_decrypt_file(find_in_parent_folders("secrets.yaml")))
}

include {
  path = find_in_parent_folders()
}

include "k8s" {
  path = find_in_parent_folders("kubernetes.hcl")
}

dependency "cluster" {
  config_path  = "../../cluster"
  skip_outputs = true
}

dependency "cert_manager" {
  config_path  = "../cert-manager"
  skip_outputs = true
}

terraform {
  source = "${dirname(find_in_parent_folders())}/../modules/k8s-issuers"
}

inputs = {
  # do_token = local.secrets.do_token
}
