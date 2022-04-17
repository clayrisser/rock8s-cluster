/**
 * File: /flux_sync.tf
 * Project: eks
 * File Created: 23-02-2022 11:40:50
 * Author: Clay Risser
 * -----
 * Last Modified: 17-04-2022 05:18:25
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

data "flux_sync" "this" {
  target_path = local.target_path
  url         = "ssh://${var.flux_git_repository}"
  branch      = var.flux_git_branch
  depends_on = [
    kubectl_manifest.flux_install
  ]
}

resource "tls_private_key" "this" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

data "kubectl_file_documents" "flux_sync" {
  content = data.flux_sync.this.content
}

locals {
  flux_sync_documents = var.flux_git_repository == "" ? [] : data.kubectl_file_documents.flux_sync.documents
  flux_sync = [for v in local.flux_sync_documents : {
    data : yamldecode(v)
    content : v
    }
  ]
}

resource "kubectl_manifest" "flux_sync" {
  for_each   = { for v in local.flux_sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body  = each.value
}

resource "kubernetes_secret" "this" {
  count      = var.flux_git_repository == "" ? 0 : 1
  depends_on = [kubectl_manifest.flux_install]
  metadata {
    name      = data.flux_sync.this.secret
    namespace = data.flux_sync.this.namespace
  }
  data = {
    identity       = tls_private_key.this.private_key_pem
    "identity.pub" = tls_private_key.this.public_key_pem
    known_hosts    = var.flux_known_hosts == "" ? var.flux_known_hosts : null
  }
  provisioner "local-exec" {
    command = "echo '${tls_private_key.this.public_key_openssh}' > ../id_ecdsa.pub"
  }
}
