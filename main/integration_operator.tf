/**
 * File: /main/integration_operator.tf
 * Project: kops
 * File Created: 21-04-2022 09:05:39
 * Author: Clay Risser
 * -----
 * Last Modified: 17-09-2022 06:55:25
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "rancher2_app_v2" "integration_operator" {
  chart_name    = "integration-operator"
  chart_version = "0.1.2"
  cluster_id    = local.rancher_cluster_id
  name          = "integration-operator"
  namespace     = "kube-system"
  repo_name     = rancher2_catalog_v2.risserlabs.name
  wait          = true
  values        = <<EOF
{}
EOF
  depends_on = [
    rancher2_app_v2.patch_operator,
    kubernetes_secret.registry
  ]
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
