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
  repository = "https://kubernetes-sigs.github.io/external-dns"

  app = {
    name          = "external-dns"
    version       = "1.9.0"
    chart         = "external-dns"
    force_update  = true
    wait          = false
    recreate_pods = false
    deploy        = 1
  }
  set_sensitive = []
  set           = []
  values = [yamlencode(
    {
      provider = "digitalocean"
      env = [
        {
          name  = "DO_TOKEN"
          value = get_env("TF_VAR_do_token")
        }
      ]
    }
  )]
}
