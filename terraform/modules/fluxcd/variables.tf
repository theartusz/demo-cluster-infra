variable "flux" {
  type = object({
    namespace   = string
    target_path = string
  })
}

variable "github" {
  type = object({
    branch                = string
    repository_name       = string
    repository_visibility = string
    owner                 = string
  })
}
