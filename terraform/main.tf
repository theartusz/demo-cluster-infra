module "kube_prometheus_stack" {
  source = "./kube_prometheus_stack"
  depends_on = [
    module.nginx
  ]

  monitoring_something = var.monitoring.monitoring
}

#module "fluxcd" {
#  source = "./fluxcd"
#
#  flux = {
#    namespace   = var.flux.namespace
#    target_path = var.flux.target_path
#  }
#  github = {
#    branch                = var.github.branch
#    repository_name       = var.github.repository_name
#    repository_visibility = var.github.repository_visibility
#    owner                 = var.github_owner
#  }
#}

module "magnifik_boutique" {
  source = "./magnifik-boutique"

  app_name   = var.app_name
  dns_prefix = var.dns_prefix
}

#module "velero" {
#  source = "./velero_backup"
#
#  azure = {
#    subscription_id = var.azure.subscription_id
#    tenant_id       = var.azure.tenant_id
#    location        = var.azure.location
#  }
#  velero = {
#    name            = var.velero.name
#    storage_account = var.velero.storage_account
#    credentials     = var.velero.credentials
#    resource_group  = var.velero.resource_group
#  }
#}

module "nginx" {
  source = "./nginx"

  nginx_ingress_controller = var.nginx_ingress_controller
}

resource "azurerm_resource_group" "k8s_resource_group" {
  name     = var.app_name
  location = var.azure.location
}

resource "azurerm_kubernetes_cluster" "magnifik_k8s" {
  name                = var.app_name
  location            = azurerm_resource_group.k8s_resource_group.location
  resource_group_name = azurerm_resource_group.k8s_resource_group.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}
