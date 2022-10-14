/**
 * File: /main/flux.tf
 * Project: kops
 * File Created: 23-02-2022 11:40:50
 * Author: Clay Risser
 * -----
 * Last Modified: 14-10-2022 10:16:32
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

data "flux_install" "this" {
  count       = var.flux ? 1 : 0
  target_path = "clusters/main"
  version     = "v0.27.2"
  components_extra = [
    "image-automation-controller",
    "image-reflector-controller"
  ]
}

resource "kubernetes_namespace" "flux_system" {
  count = var.flux ? 1 : 0
  metadata {
    name = "flux-system"
  }
  depends_on = [
    null_resource.wait_for_nodes
  ]
  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

data "kubectl_file_documents" "flux_install" {
  count   = var.flux ? 1 : 0
  content = data.flux_install.this[0].content
}

locals {
  flux_install = [for v in(length(data.kubectl_file_documents.flux_install) > 0 ? data.kubectl_file_documents.flux_install[0].documents : []) : {
    data : yamldecode(v)
    content : v
    }
  ]
}

resource "kubectl_manifest" "flux_install" {
  for_each  = { for v in local.flux_install : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  yaml_body = each.value
  depends_on = [
    kubernetes_namespace.flux_system
  ]
  lifecycle {
    prevent_destroy = false
  }
}
