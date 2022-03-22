variable "flux" {
  type = object({
    namespace   = string
    target_path = string
  })
}

variable "github" {
  type = object({
    branch          = string
    repository_name = string
    owner           = string
    token           = string
  })
}

variable "dependencies" {
  # Do the following in the module declaration:
  # dependencies = ["${some_resource.resource_alias.id}"]
  default     = []
  type        = any
  description = "Resources/modules that this module depends on. Regular `depends_on` block do not work for this module."
}
