variable "velero" {
  type = object({
    name            = string
    storage_account = string
    credentials     = string
    resource_group  = string
  })
}

variable "azure" {
  type = object({
    subscription_id = string
    tenant_id       = string
    location        = string
  })
}
