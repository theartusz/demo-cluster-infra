terraform {
  required_providers {
    // Add version constraint to providers to avoid automatic
    // upgrades resulting in breaking changes.
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.98.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.0.3"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "1.6.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "0.15.0"
    }
    github = {
      source  = "integrations/github"
      version = "4.24.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.azure.subscription_id
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.magnifik_k8s.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.magnifik_k8s.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.magnifik_k8s.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.magnifik_k8s.kube_config.0.cluster_ca_certificate)
}

provider "flux" {
  alias = "test"
}

provider "kubectl" {
  host                   = azurerm_kubernetes_cluster.magnifik_k8s.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.magnifik_k8s.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.magnifik_k8s.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.magnifik_k8s.kube_config.0.cluster_ca_certificate)
}

provider "github" {
  #owner needs to be defined for github_actions_secret to work
  owner = var.github.owner
  token = var.GITHUB_TOKEN
}
