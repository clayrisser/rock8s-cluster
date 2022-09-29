/**
 * File: /main/rancher_istio.tf
 * Project: kops
 * File Created: 18-09-2022 07:59:35
 * Author: Clay Risser
 * -----
 * Last Modified: 29-09-2022 05:36:28
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "rancher_istio" {
  source             = "../modules/helm_release"
  chart_name         = "rancher-istio"
  chart_version      = "100.4.0+up1.14.1"
  name               = "rancher-istio"
  repo               = "rancher-charts"
  namespace          = "istio-system"
  create_namespace   = true
  rancher_project_id = local.rancher_project_id
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
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
}
