/**
 * File: /flux.tf
 * Project: eks
 * File Created: 23-02-2022 11:40:50
 * Author: Clay Risser
 * -----
 * Last Modified: 14-04-2022 08:24:24
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

# provider "flux" {}

# locals {
#   branch         = "main"
#   git_repository = var.git_repository
#   target_path    = "clusters/main"
#   known_hosts    = "gitlab.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFSMqzJeV9rUzU4kWitGjeR4PWSa29SPqJ1fVkhtj3Hw9xjLVXVYrU9QlYWrOLXBpQ6KWjbjTDTdDkoohFzgbEY="
#   flux_version   = "v0.27.2"
# }

# data "flux_install" "this" {
#   target_path = local.target_path
#   version     = local.flux_version
#   components_extra = [
#     "image-automation-controller",
#     "image-reflector-controller"
#   ]
#   depends_on = [
#     time_sleep.wait_for_ingress_nginx
#   ]
# }

# data "flux_sync" "this" {
#   target_path = local.target_path
#   url         = "ssh://${local.git_repository}"
#   branch      = local.branch
#   depends_on = [
#     time_sleep.wait_for_ingress_nginx
#   ]
# }

# resource "tls_private_key" "this" {
#   algorithm   = "ECDSA"
#   ecdsa_curve = "P256"
# }

# resource "kubernetes_namespace" "flux_system" {
#   metadata {
#     name = "flux-system"
#   }
#   lifecycle {
#     ignore_changes = [
#       metadata[0].annotations,
#       metadata[0].labels,
#     ]
#   }
# }

# data "kubectl_file_documents" "install" {
#   content = data.flux_install.this.content
# }

# data "kubectl_file_documents" "sync" {
#   content = data.flux_sync.this.content
# }

# locals {
#   install = [for v in data.kubectl_file_documents.install.documents : {
#     data : yamldecode(v)
#     content : v
#     }
#   ]
#   sync = [for v in data.kubectl_file_documents.sync.documents : {
#     data : yamldecode(v)
#     content : v
#     }
#   ]
# }

# resource "kubectl_manifest" "install" {
#   for_each   = { for v in local.install : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
#   depends_on = [kubernetes_namespace.flux_system]
#   yaml_body  = each.value
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
