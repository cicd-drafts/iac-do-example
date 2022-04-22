locals {
  global = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  env    = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  region = read_terragrunt_config(find_in_parent_folders("region.hcl"))
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

terraform {
  source = "tfr://registry.terraform.io/terraform-module/release/helm?version=2.6.0"
}

inputs = {
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/ingress-nginx"

  app = {
    name          = "ingress-nginx"
    version       = "4.1.0"
    chart         = "ingress-nginx"
    force_update  = true
    wait          = false
    recreate_pods = false
    deploy        = 1
  }
  set_sensitive = []
  set           = []
  values = [yamlencode(
    {
      controller = {
        publishService = {
          enabled = true
        }
      }
    }
  )]
}
