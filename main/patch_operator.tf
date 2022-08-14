/**
 * File: /patch_operator.tf
 * Project: main
 * File Created: 21-04-2022 08:58:02
 * Author: Clay Risser
 * -----
 * Last Modified: 14-08-2022 15:00:43
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "rancher2_app_v2" "patch_operator" {
  chart_name    = "patch-operator"
  chart_version = "0.1.0"
  cluster_id    = local.rancher_cluster_id
  name          = "patch-operator"
  namespace     = "kube-system"
  repo_name     = rancher2_catalog_v2.risserlabs.name
  wait          = true
  values        = <<EOF
{}
EOF
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
