/**
 * File: /aws_auth.tf
 * Project: main
 * File Created: 17-04-2022 06:01:20
 * Author: Clay Risser
 * -----
 * Last Modified: 17-04-2022 06:56:32
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

# locals {
#   aws_auth_version       = "v0.1.0"
#   aws_auth_chart_version = "4.0.17"
#   # nginx_ingress_namespace     = "ingress-nginx"
# }

# module "aws_auth_crds" {
#   source    = "../modules/crds"
#   name      = "aws_auth-${replace(local.aws_auth_version, "/[^v0-9]/", "-")}"
#   namespace = "kube-system"
#   crds = [
#     "https://raw.githubusercontent.com/gp42/aws-auth-operator/${local.aws_auth_version}/deploy/manual/crds.yaml"
#   ]
#   depends_on = [
#     null_resource.wait_for_nodes
#   ]
# }

# resource "helm_release" "aws_auth" {
#   version          = local.aws_auth_chart_version
#   name             = "aws-auth"
#   repository       = "https://kubernetes.github.io/ingress-nginx"
#   chart            = "aws-auth"
#   namespace        = local.nginx_ingress_namespace
#   create_namespace = true
#   values = [<<EOF
# EOF
#   ]
#   depends_on = [
#     module.aws_auth_crds
#   ]
# }

##############

# resource "kubernetes_namespace" "flux_system" {
#   metadata {
#     name = "aws-auth-operator-system"
#   }
#   lifecycle {
#     ignore_changes = [
#       metadata[0].annotations,
#       metadata[0].labels,
#     ]
#   }
# }

# resource "kubernetes_secret" "registry" {
#   metadata {
#     name      = "aws-auth-operator-secret"
#     namespace = "kube-system"
#   }
#   data = {
#     AWS_ACCESS_KEY_ID     = "<key>"
#     AWS_SECRET_ACCESS_KEY = "<secret>"
#     AWS_DEFAULT_REGION    = var.region
#   }
#   type = "generic"
#   depends_on = [
#     kubernetes_namespace.flux_system
#   ]
# }
