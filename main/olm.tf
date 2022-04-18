/**
 * File: /olm.tf
 * Project: main
 * File Created: 17-04-2022 06:13:18
 * Author: Clay Risser
 * -----
 * Last Modified: 18-04-2022 10:23:26
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "kubernetes_namespace" "sn-system" {
  metadata {
    name = "sn-system"
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
  depends_on = [
    null_resource.wait_for_nodes
  ]
}

module "olm" {
  source     = "streamnative/charts/helm"
  version    = "0.8.1"
  enable_olm = true
  depends_on = [
    kubernetes_namespace.sn-system
  ]
}
