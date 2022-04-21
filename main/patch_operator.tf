/**
 * File: /patch_operator.tf
 * Project: main
 * File Created: 21-04-2022 08:58:02
 * Author: Clay Risser
 * -----
 * Last Modified: 21-04-2022 08:59:46
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "rancher2_app_v2" "patch_operator" {
  provider      = rancher2.main
  chart_name    = "patch-operator"
  chart_version = "0.0.1"
  cluster_id    = local.cluster_id
  name          = "patch-operator"
  namespace     = "kube-system"
  repo_name     = rancher2_catalog_v2.bitspur.name
  wait          = true
  values        = <<EOF
{}
EOF
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
