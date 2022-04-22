data "digitalocean_kubernetes_versions" "this" {
  version_prefix = "1.22."
}

resource "digitalocean_kubernetes_cluster" "this" {
  name         = var.name
  region       = var.region
  auto_upgrade = true
  version      = data.digitalocean_kubernetes_versions.this.latest_version

  maintenance_policy {
    start_time = "04:00"
    day        = "sunday"
  }

  node_pool {
    name       = "default"
    size       = var.node_type
    node_count = var.node_count
  }
}
