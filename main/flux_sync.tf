/**
 * File: /flux_sync.tf
 * Project: eks
 * File Created: 23-02-2022 11:40:50
 * Author: Clay Risser
 * -----
 * Last Modified: 15-04-2022 14:59:32
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

# provider "flux" {}

# locals {
#   branch         = "main"
#   git_repository = var.git_repository
#   known_hosts    = "gitlab.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFSMqzJeV9rUzU4kWitGjeR4PWSa29SPqJ1fVkhtj3Hw9xjLVXVYrU9QlYWrOLXBpQ6KWjbjTDTdDkoohFzgbEY="
# }

# data "flux_sync" "this" {
#   target_path = local.target_path
#   url         = "ssh://${local.git_repository}"
#   branch      = local.branch
#   depends_on = [
#     kubernetes_namespace.flux_system
#   ]
# }

# resource "tls_private_key" "this" {
#   algorithm   = "ECDSA"
#   ecdsa_curve = "P256"
# }

# data "kubectl_file_documents" "sync" {
#   content = data.flux_sync.this.content
# }

# locals {
#   sync = [for v in data.kubectl_file_documents.sync.documents : {
#     data : yamldecode(v)
#     content : v
#     }
#   ]
# }

# resource "kubectl_manifest" "sync" {
#   for_each   = { for v in local.sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
#   depends_on = [kubernetes_namespace.flux_system]
#   yaml_body  = each.value
# }

# resource "kubernetes_secret" "this" {
#   depends_on = [kubectl_manifest.install]
#   metadata {
#     name      = data.flux_sync.this.secret
#     namespace = data.flux_sync.this.namespace
#   }
#   data = {
#     identity       = tls_private_key.this.private_key_pem
#     "identity.pub" = tls_private_key.this.public_key_pem
#     known_hosts    = local.known_hosts
#   }
#   provisioner "local-exec" {
#     command = "echo '${tls_private_key.this.public_key_openssh}' > ../id_ecdsa.pub"
#   }
# }
