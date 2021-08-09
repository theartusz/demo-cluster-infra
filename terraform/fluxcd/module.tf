terraform {
  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = "0.2.0"
    }
    github = {
      source  = "integrations/github"
      version = ">= 4.5.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }
  }
}

# creates private key to be used as deployment keys for repo
resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# create flux-system namespace
resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = var.flux.namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }
}

data "flux_install" "main" {
  target_path = "test-cluster"
}

data "flux_sync" "main" {
  target_path = var.flux.target_path
  url         = "ssh://git@github.com/${var.github.owner}/${var.github.repository_name}.git"
  branch      = var.github.branch
}

# splits the combined yaml to single yaml manifests
data "kubectl_file_documents" "install" {
  content = data.flux_install.main.content
}

# splits the combined yaml to single yaml manifests
data "kubectl_file_documents" "sync" {
  content = data.flux_sync.main.content
}

locals {
  install = [for v in data.kubectl_file_documents.install.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
  sync = [for v in data.kubectl_file_documents.sync.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
  # ssh-rsa key to fluxcd github repo to download fluxcd from
  known_hosts = "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=="
}

# apply kubernetes manifests
resource "kubectl_manifest" "install" {
  for_each   = { for v in local.install : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body  = each.value
}

# apply kubernetes manifests
resource "kubectl_manifest" "sync" {
  for_each   = { for v in local.sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body  = each.value
}

# create kubernetes secret with data for flux
resource "kubernetes_secret" "main" {
  depends_on = [kubectl_manifest.install]

  metadata {
    name      = data.flux_sync.main.secret
    namespace = data.flux_sync.main.namespace
  }

  data = {
    identity       = tls_private_key.main.private_key_pem
    "identity.pub" = tls_private_key.main.public_key_pem
    known_hosts    = local.known_hosts
  }
}

# create new github repository
resource "github_repository" "main" {
  name       = var.github.repository_name
  visibility = var.github.repository_visibility
  auto_init  = true
}

# make branch default
resource "github_branch_default" "main" {
  repository = github_repository.main.name
  branch     = var.github.branch
}

# add deploy key to the newly created git repo
resource "github_repository_deploy_key" "main" {
  title      = "flux-key"
  repository = github_repository.main.name
  key        = tls_private_key.main.public_key_openssh
  read_only  = true
  depends_on = [
    github_repository.main
  ]
}

# create file in gihub containing flux crd's
resource "github_repository_file" "install" {
  repository = github_repository.main.name
  file       = data.flux_install.main.path
  content    = data.flux_install.main.content
  branch     = var.github.branch
}

# create file in github containing GitRepository, Kustomization
resource "github_repository_file" "sync" {
  repository = github_repository.main.name
  file       = data.flux_sync.main.path
  content    = data.flux_sync.main.content
  branch     = var.github.branch
}

# create file in github with kind: Kustomization
resource "github_repository_file" "kustomize" {
  repository = github_repository.main.name
  file       = data.flux_sync.main.kustomize_path
  content    = data.flux_sync.main.kustomize_content
  branch     = var.github.branch
}
