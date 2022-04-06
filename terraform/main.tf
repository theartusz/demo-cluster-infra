resource "azurerm_resource_group" "k8s_resource_group" {
  name     = var.azure.resource_group_name
  location = var.azure.location
  tags     = var.tags
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

  tags = var.tags
}

resource "azurerm_container_registry" "acr" {
  name                = var.azure.acr_name
  resource_group_name = azurerm_resource_group.k8s_resource_group.name
  location            = azurerm_resource_group.k8s_resource_group.location
  sku                 = "Basic"
  admin_enabled       = true
  tags                = var.tags
}

resource "github_actions_secret" "acr-registry" {
  repository      = var.app_angular.repository
  secret_name     = var.app_angular.action_secret_registry
  plaintext_value = azurerm_container_registry.acr.login_server
}

resource "github_actions_secret" "acr-username" {
  repository      = var.app_angular.repository
  secret_name     = var.app_angular.action_secret_username
  plaintext_value = azurerm_container_registry.acr.admin_username
}

resource "github_actions_secret" "acr-password" {
  repository      = var.app_angular.repository
  secret_name     = var.app_angular.action_secret_password
  plaintext_value = azurerm_container_registry.acr.admin_password
}

#resource "kubectl_manifest" "acr-auth" {
#  sensitive_fields = ["data"]
#  yaml_body        = <<YAML
#  apiVersion: v1
#  kind: Secret
#  metadata:
#    name: acr-cred
#    namespace: flux-system
#  type: kubernetes.io/dockerconfigjson
#  data:
#    .dockerconfigjson: ${base64encode({ "auths" : { "${azurerm_container_registry.acr.login_server}" : { "username" : "${azurerm_container_registry.acr.admin_username}", "password" : "${azurerm_container_registry.acr.admin_password}", "auth" : "${base64encode(azurerm_container_registry.acr.login_server)}" } } })}
#YAML
#}

module "fluxcd" {
  source = "./modules/fluxcd"

  flux = {
    namespace   = var.flux.namespace
    target_path = var.flux.target_path
  }
  github = {
    branch          = var.github.branch
    repository_name = var.github.repository_name
    owner           = var.GITHUB_OWNER
    token           = var.GITHUB_TOKEN
  }
  dependencies = ["azurerm_kubernetes_cluster.magnifik_k8s"]
}

#module "magnifik_boutique" {
#  source = "./modules/magnifik-boutique"
#
#  app_name   = var.app_name
#  dns_prefix = var.dns_prefix
#}

#module "velero" {
#  source = "./modules/velero"
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


