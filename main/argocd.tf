/**
 * File: /argocd.tf
 * Project: main
 * File Created: 04-10-2023 16:04:43
 * Author: Clay Risser
 * -----
 * BitSpur (c) Copyright 2021 - 2023
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

data "gitlab_project" "this" {
  id = var.gitlab_project_id
}

module "argocd" {
  source  = "../modules/argocd"
  enabled = var.argocd
  depends_on = [
    null_resource.wait-for-cluster
  ]
}

data "kubernetes_secret" "argocd-initial-admin-secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
  depends_on = [
    module.argocd
  ]
}

provider "argocd" {
  username                    = "admin"
  password                    = try(data.kubernetes_secret.argocd-initial-admin-secret.data.password, null)
  port_forward_with_namespace = "argocd"
  kubernetes {
    host     = local.cluster_endpoint
    insecure = true
    exec {
      api_version = local.user_exec.api_version
      command     = local.user_exec.command
      args        = local.user_exec.args
    }
  }
}

resource "argocd_repository" "git" {
  repo     = data.gitlab_project.this.http_url_to_repo
  username = var.gitlab_username
  password = var.gitlab_token
  insecure = false
}

resource "argocd_application" "apps" {
  metadata {
    name      = "apps"
    namespace = "argocd"
  }
  spec {
    project = "default"
    source {
      repo_url        = argocd_repository.git.repo
      target_revision = "main"
      path            = "apps"
      directory {
        recurse = false
      }
    }
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "argocd"
    }
    sync_policy {
      sync_options = [
        "CreateNamespace=true"
      ]
    }
  }
}
