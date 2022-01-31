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

variable "monitoring" {
  type = object({
    prometheus = string
    monitoring = string
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
    repository_name       = string
    repository_visibility = string
    branch                = string
  })
}

variable "github_token" {
  type      = string
  sensitive = true
}

variable "github_owner" {
  type = string
}

variable "flux" {
  type = object({
    namespace   = string
    target_path = string
  })
}

variable "cert_manager" {
  type = object({
    name = string
  })
}
