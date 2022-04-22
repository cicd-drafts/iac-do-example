locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  env_vars    = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  alias       = local.global_vars.locals.alias
  environment = local.env_vars.locals.environment
}

generate "provider-k8s" {
  path      = "provider-k8s.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
data "digitalocean_kubernetes_cluster" "this" {
  name = "${local.alias}-${local.environment}"
}

provider "kubernetes" {
  host                   = data.digitalocean_kubernetes_cluster.this.endpoint
  token                  = data.digitalocean_kubernetes_cluster.this.kube_config[0].token
  cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.digitalocean_kubernetes_cluster.this.endpoint
    token                  = data.digitalocean_kubernetes_cluster.this.kube_config[0].token
    cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
  }
}
EOF
}
