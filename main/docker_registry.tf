/**
 * File: /docker_registry.tf
 * Project: main
 * File Created: 24-02-2022 16:17:10
 * Author: Clay Risser
 * -----
 * Last Modified: 14-04-2022 08:24:18
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

# locals {
#   kubed_chart_version = "v0.13.0"
#   gitlab_registry     = "registry.gitlab.com"
#   gitlab_username     = var.gitlab_username
#   gitlab_password     = var.gitlab_password
# }

# resource "helm_release" "kubed" {
#   version          = local.kubed_chart_version
#   name             = "kubed"
#   repository       = "https://charts.appscode.com/stable"
#   chart            = "kubed"
#   namespace        = "kube-system"
#   create_namespace = true
#   values = [<<EOF
# EOF
#   ]
#   depends_on = [
#     null_resource.wait_for_nodes
#   ]
# }

# data "aws_ecr_authorization_token" "this" {}

# resource "kubernetes_secret" "ecr_registry" {
#   metadata {
#     name      = "registry"
#     namespace = "kube-system"
#     annotations = {
#       "kubed.appscode.com/sync" = ""
#     }
#   }
#   data = {
#     ".dockerconfigjson" = jsonencode({
#       auths = {
#         "${data.aws_ecr_authorization_token.this.proxy_endpoint}" = {
#           auth = "${base64encode("${data.aws_ecr_authorization_token.this.user_name}:${data.aws_ecr_authorization_token.this.password}")}"
#         },
#         "${local.gitlab_registry}" = {
#           auth = "${base64encode("${local.gitlab_username}:${local.gitlab_password}")}"
#         }
#       }
#     })
#   }
#   type = "kubernetes.io/dockerconfigjson"
#   depends_on = [
#     helm_release.kubed
#   ]
# }
