/**
 * File: /main/istio.tf
 * Project: kops
 * File Created: 18-09-2022 07:59:35
 * Author: Clay Risser
 * -----
 * Last Modified: 21-09-2022 10:36:59
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "rancher2_app_v2" "istio" {
  chart_name    = "istio"
  chart_version = "100.4.0+up1.14.1"
  cluster_id    = local.rancher_cluster_id
  name          = "istio"
  namespace     = rancher2_namespace.cattle_logging_system.name
  repo_name     = "istio"
  wait          = true
  values        = <<EOF
cni:
  enabled: true
egressGateways:
  enabled: true
tracing:
  enabled: true
EOF
  depends_on    = []
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "rancher2_namespace" "istio" {
  name       = "istio"
  project_id = data.rancher2_project.system.id
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
