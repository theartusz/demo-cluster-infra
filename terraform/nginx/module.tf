resource "kubernetes_namespace" "ingress_controller_namespace" {
  metadata {
    name = var.nginx_ingress_controller
  }
}

resource "helm_release" "ingress_controller" {
  name       = var.nginx_ingress_controller
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = var.nginx_ingress_controller
}
