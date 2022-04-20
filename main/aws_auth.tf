/**
 * File: /aws_auth.tf
 * Project: main
 * File Created: 17-04-2022 06:01:20
 * Author: Clay Risser
 * -----
 * Last Modified: 20-04-2022 05:40:39
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

# locals {
#   aws_auth_version = "main"
# }

# resource "kubernetes_namespace" "aws_auth_operator_system" {
#   metadata {
#     name = "aws-auth-operator-system"
#   }
#   lifecycle {
#     ignore_changes = [
#       metadata[0].annotations,
#       metadata[0].labels,
#     ]
#   }
#   depends_on = [
#     null_resource.wait_for_nodes
#   ]
# }

# module "aws_auth_crds" {
#   source    = "../modules/kubernetes_resources"
#   name      = "aws-auth-crds-${local.aws_auth_version}"
#   namespace = "kube-system"
#   resources = [
#     "https://raw.githubusercontent.com/gp42/aws-auth-operator/${local.aws_auth_version}/deploy/manual/crds.yaml"
#   ]
#   depends_on = [
#     kubernetes_namespace.aws_auth_operator_system
#   ]
# }

# resource "kubernetes_secret" "aws_auth_registry" {
#   metadata {
#     name      = "aws-auth-operator-secret"
#     namespace = "kube-system"
#   }
#   data = {
#     AWS_ACCESS_KEY_ID     = var.aws_access_key_id
#     AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key
#     AWS_DEFAULT_REGION    = var.region
#   }
#   depends_on = [
#     module.aws_auth_crds
#   ]
# }

# module "aws_auth_install" {
#   source    = "../modules/kubernetes_resources"
#   name      = "aws-auth-install-${local.aws_auth_version}"
#   namespace = "kube-system"
#   resources = [
#     "https://raw.githubusercontent.com/gp42/aws-auth-operator/${local.aws_auth_version}/deploy/manual/serviceaccount.yaml",
#     "https://raw.githubusercontent.com/gp42/aws-auth-operator/${local.aws_auth_version}/deploy/manual/deployment.yaml",
#     "https://raw.githubusercontent.com/gp42/aws-auth-operator/${local.aws_auth_version}/deploy/manual/role.yaml",
#     "https://raw.githubusercontent.com/gp42/aws-auth-operator/${local.aws_auth_version}/deploy/manual/role_binding.yaml",
#     "https://raw.githubusercontent.com/gp42/aws-auth-operator/${local.aws_auth_version}/deploy/manual/role_leader_election.yaml",
#     "https://raw.githubusercontent.com/gp42/aws-auth-operator/${local.aws_auth_version}/deploy/manual/role_binding_leader_election.yaml"
#   ]
#   depends_on = [
#     kubernetes_secret.aws_auth_registry
#   ]
# }
