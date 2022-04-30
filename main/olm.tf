/**
 * File: /olm.tf
 * Project: main
 * File Created: 17-04-2022 06:13:18
 * Author: Clay Risser
 * -----
 * Last Modified: 30-04-2022 12:28:11
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "kubernetes_namespace" "sn_system" {
  metadata {
    name = "sn-system"
  }
  depends_on = [
    null_resource.wait_for_nodes
  ]
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

module "olm" {
  source                        = "streamnative/charts/helm"
  version                       = "0.8.1"
  enable_function_mesh_operator = false
  enable_istio_operator         = false
  enable_kiali_operator         = false
  enable_olm                    = true
  enable_otel_collector         = false
  enable_prometheus_operator    = false
  enable_pulsar_operator        = false
  enable_vault_operator         = false
  enable_vector_agent           = false
  enable_vmagent                = false
  depends_on = [
    kubernetes_namespace.sn_system
  ]
}
