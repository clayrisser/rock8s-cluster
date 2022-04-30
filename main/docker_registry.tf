/**
 * File: /docker_registry.tf
 * Project: main
 * File Created: 24-02-2022 16:17:10
 * Author: Clay Risser
 * -----
 * Last Modified: 30-04-2022 12:23:11
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

locals {
  gitlab_registry = "registry.${var.gitlab_hostname}"
}

data "aws_ecr_authorization_token" "this" {}

resource "kubernetes_secret" "registry" {
  metadata {
    name      = "registry"
    namespace = "kube-system"
    annotations = {
      "kubed.appscode.com/sync" = ""
    }
  }
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${data.aws_ecr_authorization_token.this.proxy_endpoint}" = {
          auth = "${base64encode("${data.aws_ecr_authorization_token.this.user_name}:${data.aws_ecr_authorization_token.this.password}")}"
        },
        "${local.gitlab_registry}" = {
          auth = "${base64encode("${var.gitlab_registry_username}:${var.gitlab_registry_token}")}"
        }
      }
    })
  }
  type = "kubernetes.io/dockerconfigjson"
  depends_on = [
    helm_release.kubed
  ]
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
