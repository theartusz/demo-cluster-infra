resource "gitlab_cluster_agent" "artur_test" {
  project = "2808"
  name    = "agent-1"
}

resource "gitlab_repository_file" "agent_config" {
  project        = gitlab_cluster_agent.artur_test.project
  branch         = "master"
  file_path      = ".gitlab/agents/${gitlab_cluster_agent.artur_test.name}/config.yaml"
  content        = <<CONTENT
  gitops:
  ...
  CONTENT
  author_email   = "artur.ferfecki@sikt.no"
  author_name    = "Artur Ferfecki"
  commit_message = "feature: add agent config for ${gitlab_cluster_agent.artur_test.name}"
}

# waitin for gitlab to be upgraded to v 15
#resource "gitlab_cluster_agent_token" "agent_token" {
#  project     = "2808"
#  agent_id    = gitlab_cluster_agent.artur_test.agent_id
#  name        = "test-agent-token"
#  description = "token for agent used by helm chart"
#}

resource "helm_release" "gitlab_agent" {
  name             = "gitlab-agent"
  namespace        = "gitlab-agent"
  create_namespace = true
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-agent"
  version          = "1.2.0"

  set {
    name  = "config.token"
    value = "9"
  }
}
