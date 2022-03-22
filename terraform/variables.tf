variable "app_name" {
  type = string
}

variable "nginx_ingress_controller" {
  type = string
}

variable "azure" {
  type = object({
    subscription_id = string
    tenant_id       = string
    dns_zone_name   = string
    location        = string
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
    owner                 = string
    repository_name       = string
    repository_visibility = string
    branch                = string
  })
}

variable "token" {
  type      = string
  sensitive = true
}

variable "flux" {
  type = object({
    namespace   = string
    target_path = string
  })
}
