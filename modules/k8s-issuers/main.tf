resource "kubernetes_secret" "cluster_issuer" {
  metadata {
    name      = "${var.issuer_name}-issuer"
    namespace = var.namespace
  }

  data = {
    access-token = var.do_token
  }
}

resource "kubernetes_manifest" "cluster_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = var.issuer_name
    }
    spec = {
      acme = {
        email  = "gimadiev.kzn@yandex.ru"
        server = "https://acme-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = "${var.issuer_name}-issuer-account-key"
        }
        solvers = [
          {
            dns01 = {
              digitalocean = {
                tokenSecretRef = {
                  name = kubernetes_secret.cluster_issuer.metadata[0].name
                  key  = "access-token"
                }
              }
            }
          }
        ]
      }
    }
  }
}
