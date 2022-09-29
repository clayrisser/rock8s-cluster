/**
 * File: /main/flux_sync.tf
 * Project: kops
 * File Created: 23-02-2022 11:40:50
 * Author: Clay Risser
 * -----
 * Last Modified: 29-09-2022 11:23:19
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

data "flux_sync" "this" {
  count       = var.flux ? 1 : 0
  target_path = "clusters/main"
  url         = "ssh://${var.flux_git_repository == "" ? "localhost" : var.flux_git_repository}"
  branch      = var.flux_git_branch
  depends_on = [
    kubectl_manifest.flux_install
  ]
}

resource "tls_private_key" "flux" {
  count       = var.flux ? 1 : 0
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

data "kubectl_file_documents" "flux_sync" {
  count   = var.flux ? 1 : 0
  content = data.flux_sync.this[0].content
}

locals {
  flux_sync_documents = (var.flux_git_repository != "" && length(data.kubectl_file_documents.flux_sync) > 0) ? data.kubectl_file_documents.flux_sync[0].documents : []
  flux_sync = [for v in local.flux_sync_documents : {
    data : yamldecode(v)
    content : v
    }
  ]
}

resource "kubectl_manifest" "flux_sync" {
  for_each  = { for v in local.flux_sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  yaml_body = each.value
  depends_on = [
    kubectl_manifest.flux_install
  ]
}

resource "kubernetes_secret" "flux_sync" {
  count = (!var.flux || var.flux_git_repository == "") ? 0 : 1
  metadata {
    name      = data.flux_sync.this[0].secret
    namespace = data.flux_sync.this[0].namespace
  }
  data = {
    identity       = tls_private_key.flux[0].private_key_pem
    "identity.pub" = tls_private_key.flux[0].public_key_pem
    known_hosts    = var.flux_known_hosts == "" ? var.flux_known_hosts : null
  }
  provisioner "local-exec" {
    command = "echo '${tls_private_key.flux[0].public_key_openssh}' > ../flux_ecdsa.pub"
  }
  depends_on = [
    kubectl_manifest.flux_sync
  ]
}
