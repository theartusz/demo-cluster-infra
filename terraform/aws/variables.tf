variable "aws" {
  type = object({
    cluster_name = string
    prefix_name  = string
  })
}

variable "GITHUB_TOKEN" {
  description = "github token"
  type        = string
  sensitive   = true
}

variable "GITLAB_TOKEN" {
  type      = string
  sensitive = true
}
variable "github" {
  type = object({
    owner           = string
    repository_name = string
    branch          = string
  })
}

variable "flux" {
  type = object({
    namespace   = string
    target_path = string
  })
}
