terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.23.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.2"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = ">= 0.11.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
    github = {
      source  = "integrations/github"
      version = ">= 4.24.1"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "3.16.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0"
    }
  }
}

provider "aws" {}

provider "flux" {}

provider "kubectl" {
  host                   = aws_eks_cluster.magnifik.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.magnifik.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token
}

provider "kubernetes" {
  host                   = aws_eks_cluster.magnifik.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.magnifik.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token
}

provider "github" {
  owner = var.github_owner
  token = var.github_token
}

provider "gitlab" {
  base_url = "https://gitlab.sikt.no/api/v4/"
  token    = var.GITLAB_TOKEN
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.magnifik.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.magnifik.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.default.token
  }
}
