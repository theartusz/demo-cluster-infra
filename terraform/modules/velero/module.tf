terraform {
  required_providers {
    #azurerm = {
    #  source  = "hashicorp/azurerm"
    #  version = ">=2.46.0"
    #}
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.0.3"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.22.0"
    }
  }
}

# create separate resource group for backups
resource "azurerm_resource_group" "velero_backup" {
  name     = var.velero.resource_group
  location = var.azure.location
}

# create dedicated  namespace for velero
resource "kubernetes_namespace" "velero" {
  metadata {
    name = var.velero.name
  }
}

# create store account for velero
resource "azurerm_storage_account" "velero" {
  name                      = var.velero.storage_account
  resource_group_name       = azurerm_resource_group.velero_backup.name
  location                  = azurerm_resource_group.velero_backup.location
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  account_kind              = "BlobStorage"
  access_tier               = "Hot"
  enable_https_traffic_only = true
}

# create storage container (blob) where to store backups
resource "azurerm_storage_container" "velero" {
  name                  = var.velero.name
  storage_account_name  = azurerm_storage_account.velero.name
  container_access_type = "private"
}

# create new Azure Active Directory application (identity) for velero
resource "azuread_application" "velero" {
  display_name = "velero"
}

# create service principal for the newly created AAD application
# which will be used for authenticating to the storage account
resource "azuread_service_principal" "velero" {
  application_id = azuread_application.velero.application_id
}

# create new password for the application
resource "azuread_application_password" "velero" {
  application_object_id = azuread_application.velero.object_id
  display_name          = "velero-password"
}

# give service principal contributor role
resource "azurerm_role_assignment" "velero" {
  scope                = "/subscriptions/${var.azure.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.velero.object_id
  depends_on = [
    azuread_service_principal.velero,
  ]
}

# inject azure env variables into the templete file
data "template_file" "velero_credentials" {
  template = file("../config/velero-config/credentials-template")
  vars = {
    AZURE_SUBSCRIPTION_ID = var.azure.subscription_id
    AZURE_TENANT_ID       = var.azure.tenant_id
    AZURE_CLIENT_ID       = azuread_service_principal.velero.application_id
    AZURE_CLIENT_SECRET   = azuread_application_password.velero.value
    AZURE_RESOURCE_GROUP  = "MC_magnifik-boutique_magnifik-boutique_westeurope"
    AZURE_CLOUD_NAME      = "AzurePublicCloud"
  }
}

# create kubernetes secret from the template file
resource "kubernetes_secret" "velero_credentials" {
  metadata {
    name      = var.velero.credentials
    namespace = kubernetes_namespace.velero.metadata[0].name
  }
  data = {
    cloud = data.template_file.velero_credentials.rendered
  }
}

# inject values into velero helm chart values template
data "template_file" "velero_values" {
  template = file("../config/velero-config/helm-chart-values.yaml")
  vars = {
    provider              = "azure"
    storage_account_name  = azurerm_storage_account.velero.name
    backup_container_name = azurerm_storage_container.velero.name
    velero_secret         = kubernetes_secret.velero_credentials.metadata[0].name
    backup_resource_group = azurerm_resource_group.velero_backup.name
    subscription_id       = var.azure.subscription_id
  }
}

# install velero with helm chart
resource "helm_release" "velero" {
  name       = var.velero.name
  repository = "https://vmware-tanzu.github.io/helm-charts"
  chart      = "velero"
  namespace  = kubernetes_namespace.velero.metadata.0.name
  values     = [data.template_file.velero_values.rendered]
}

