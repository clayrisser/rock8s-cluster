/**
 * File: /helm_controller.tf
 * Project: main
 * File Created: 07-05-2022 03:17:43
 * Author: Clay Risser
 * -----
 * Last Modified: 12-08-2022 14:14:04
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "rancher2_app_v2" "helm_controller" {
  chart_name    = "helm-controller"
  chart_version = "0.12.3"
  cluster_id    = local.rancher_cluster_id
  name          = "helm-controller"
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