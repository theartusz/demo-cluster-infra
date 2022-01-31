resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = var.cert_manager.name
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = var.cert_manager.name
}
