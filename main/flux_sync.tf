/**
 * File: /flux_sync.tf
 * Project: eks
 * File Created: 23-02-2022 11:40:50
 * Author: Clay Risser
 * -----
 * Last Modified: 24-04-2022 08:54:53
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

# data "flux_sync" "this" {
#   target_path = local.target_path
#   url         = "ssh://${var.flux_git_repository == "" ? "localhost" : var.flux_git_repository}"
#   branch      = var.flux_git_branch
#   depends_on = [
#     kubectl_manifest.flux_install
#   ]
# }

# resource "tls_private_key" "this" {
#   algorithm   = "ECDSA"
#   ecdsa_curve = "P256"
# }

# data "kubectl_file_documents" "flux_sync" {
#   content = data.flux_sync.this.content
# }

# locals {
#   flux_sync_documents = var.flux_git_repository == "" ? [] : data.kubectl_file_documents.flux_sync.documents
#   flux_sync = [for v in local.flux_sync_documents : {
#     data : yamldecode(v)
#     content : v
#     }
#   ]
# }

# resource "kubectl_manifest" "flux_sync" {
#   for_each  = { for v in local.flux_sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
#   yaml_body = each.value
#   depends_on = [
#     kubectl_manifest.flux_install
#   ]
# }

# resource "kubernetes_secret" "flux_sync" {
#   count = var.flux_git_repository == "" ? 0 : 1
#   metadata {
#     name      = data.flux_sync.this.secret
#     namespace = data.flux_sync.this.namespace
#   }
#   data = {
#     identity       = tls_private_key.this.private_key_pem
#     "identity.pub" = tls_private_key.this.public_key_pem
#     known_hosts    = var.flux_known_hosts == "" ? var.flux_known_hosts : null
#   }
#   provisioner "local-exec" {
#     command = "echo '${tls_private_key.this.public_key_openssh}' > ../id_ecdsa.pub"
#   }
#   depends_on = [
#     kubectl_manifest.flux_sync
#   ]
# }

# module "deploy_key" {
#   count          = var.flux_git_repository == "" ? 0 : 1
#   source         = "../modules/deploy_key/gitlab"
#   name           = local.cluster_name
#   gitlab_project = var.gitlab_project_id
#   providers = {
#     gitlab = gitlab
#   }
#   depends_on = [
#     kubernetes_secret.flux_sync
#   ]
# }
