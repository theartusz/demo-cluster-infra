module "fluxcd" {
  source = "../modules/fluxcd"

  flux = {
    namespace   = var.flux.namespace
    target_path = var.flux.target_path
  }
  github = {
    branch          = var.github.branch
    repository_name = var.github.repository_name
    owner           = var.github.owner
    token           = var.GITHUB_TOKEN
  }
  dependencies = ["aws_eks_cluster.magnifik"]
}
