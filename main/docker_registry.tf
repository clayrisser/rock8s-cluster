/**
 * File: /main/docker_registry.tf
 * Project: kops
 * File Created: 24-02-2022 16:17:10
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:05:21
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
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
  }
}
