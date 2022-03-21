# creates private key to be used as deployment keys for repo
resource "tls_private_key" "main" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
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
  # option to specify which components of flux to install
  #components = [
  #  "source-controller",
  #  "kustomize-controller",
  #  "image-automation-controller",
  #  "image-reflector-controller"
  #]
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
  known_hosts = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
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

resource "github_repository_deploy_key" "main" {
  title      = "fluxcd-key"
  repository = var.github.repository_name
  key        = tls_private_key.main.public_key_openssh
  read_only  = true
}

resource "kubernetes_network_policy" "allow_all_ingress" {
  metadata {
    name      = "allow-all-ingress"
    namespace = kubernetes_namespace.flux_system.metadata.0.name
  }

  spec {
    pod_selector {}
    ingress {}
    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "allow_all_egress" {
  metadata {
    name      = "allow-all-egress"
    namespace = kubernetes_namespace.flux_system.metadata.0.name
  }

  spec {
    pod_selector {}
    egress {}
    policy_types = ["Egress"]
  }
}

# add deploy key to specified repo to give flux access to that repo

