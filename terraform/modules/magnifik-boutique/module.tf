terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.46.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.0.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.9.0"
    }
  }
}

resource "kubernetes_namespace" "magnifik_boutique" {
  metadata {
    name = var.app_name
  }
}

resource "helm_release" "online_boutique_helm" {
  name      = "online-boutique"
  chart     = "../online-boutique"
  namespace = kubernetes_namespace.magnifik_boutique.metadata[0].name
}

