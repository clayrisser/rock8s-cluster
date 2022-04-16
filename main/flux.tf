/**
 * File: /flux.tf
 * Project: eks
 * File Created: 23-02-2022 11:40:50
 * Author: Clay Risser
 * -----
 * Last Modified: 15-04-2022 15:00:06
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

locals {
  target_path  = "clusters/main"
  flux_version = "v0.27.2"
}

data "flux_install" "this" {
  target_path = local.target_path
  version     = local.flux_version
  components_extra = [
    "image-automation-controller",
    "image-reflector-controller"
  ]
  depends_on = [
    null_resource.wait_for_nodes
  ]
}

resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = "flux-system"
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

data "kubectl_file_documents" "install" {
  content = data.flux_install.this.content
}

locals {
  install = [for v in data.kubectl_file_documents.install.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
}

resource "kubectl_manifest" "install" {
  for_each   = { for v in local.install : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body  = each.value
}
