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

dependency "ingres" {
  config_path  = "../ingress-controller"
  skip_outputs = true
}

terraform {
  source = "tfr://registry.terraform.io/terraform-module/release/helm?version=2.6.0"
}

inputs = {
  namespace  = "default"
  repository = "https://helm.nano-byte.net/"

  app = {
    name          = "application"
    version       = "1.3.0"
    chart         = "generic-service"
    force_update  = true
    wait          = false
    recreate_pods = false
    deploy        = 1
  }
  set_sensitive = []
  set           = []
  values = [yamlencode(
    {
      fullname = "application"
      name     = "application"
      image = {
        registry   = "ghcr.io"
        repository = "${local.global.locals.organization}/${local.global.locals.repository}"
        tag        = "main"
      }
      ingress = {
        tls = {
          enabled = true
        }
        annotations = {
          "cert-manager.io/cluster-issuer" = "default"
        }
        port    = 11130
        enabled = true
        class   = "nginx"
        domains = [
          "janbo.gimadiev.live"
        ]
      }
    }
  )]
}
