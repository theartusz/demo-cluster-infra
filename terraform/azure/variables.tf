variable "azure" {
  type = object({
    subscription_id     = string
    tenant_id           = string
    dns_zone_name       = string
    location            = string
    resource_group_name = string
    acr_name            = string
  })
}

variable "app_name" {
  type = string
}

variable "app_angular" {
  type = object({
    name                   = string
    repository             = string
    action_secret_username = string
    action_secret_password = string
    action_secret_registry = string
  })
}

variable "dns_prefix" {
  type = string
}

variable "velero" {
  type = object({
    name            = string
    storage_account = string
    credentials     = string
    resource_group  = string
  })
}

variable "github" {
  type = object({
    owner           = string
    repository_name = string
    branch          = string
  })
}

variable "GITHUB_TOKEN" {
  type      = string
  sensitive = true
}

variable "flux" {
  type = object({
    namespace   = string
    target_path = string
  })
}

variable "tags" {
  type = map(any)
}
