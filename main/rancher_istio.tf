/**
 * File: /main/rancher_istio.tf
 * Project: kops
 * File Created: 18-09-2022 07:59:35
 * Author: Clay Risser
 * -----
 * Last Modified: 21-09-2022 10:39:43
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "rancher2_app_v2" "rancher_istio" {
  chart_name    = "rancher-istio"
  chart_version = "100.4.0+up1.14.1"
  cluster_id    = local.rancher_cluster_id
  name          = "rancher-istio"
  namespace     = rancher2_namespace.cattle_logging_system.name
  repo_name     = "rancher-istio"
  wait          = true
  values        = <<EOF
cni:
  enabled: true
egressGateways:
  enabled: true
tracing:
  enabled: true
EOF
  depends_on = [
    time_sleep.rancher_monitoring_ready
  ]
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "rancher2_namespace" "istio_system" {
  name       = "istio-system"
  project_id = data.rancher2_project.system.id
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
