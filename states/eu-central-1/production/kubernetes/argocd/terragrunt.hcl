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
  namespace  = "kube-public"
  repository = "https://argoproj.github.io/argo-helm"

  app = {
    name          = "argo-cd"
    version       = "4.5.5"
    chart         = "argo-cd"
    force_update  = true
    wait          = false
    recreate_pods = false
    deploy        = 1
  }
  set_sensitive = []
  set           = []
  values = [yamlencode(
    {
      additionalApplications = [
        {
          name    = "root"
          project = "default"
          source = {
            repoURL        = "https://github.com/${local.global.locals.organization}/${local.global.locals.repository}.git"
            path           = "generated"
            targetRevision = "HEAD"
            directory = {
              recurse = true
            }
          }
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "kube-public"
          }
          syncPolicy = {
            automated = {
              prune    = false
              selfHeal = false
            }
          }
        }
      ]
      config = {
        repositories = yamlencode(
          [
            {
              url = "git@github.com:${local.global.locals.organization}/${local.global.locals.repository}.git"
            }
          ]
        )
      }
    }
  )]
}
