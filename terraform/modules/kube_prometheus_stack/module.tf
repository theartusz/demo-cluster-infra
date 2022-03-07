terraform {
  required_providers {

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.0.3"
    }
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.monitoring
  }
}

resource "helm_release" "prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = var.monitoring
  values     = ["${file("../config/kube-prometheus-stack-config/helm-chart-values.yaml")}"]
}
