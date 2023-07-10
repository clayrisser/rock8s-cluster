/**
 * File: /main/rancher_istio.tf
 * Project: kops
 * File Created: 18-09-2022 07:59:35
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:09:29
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

module "rancher_istio" {
  source             = "../modules/helm_release"
  enabled            = local.rancher_istio
  chart_name         = "rancher-istio"
  chart_version      = "100.4.0+up1.14.1"
  name               = "rancher-istio"
  repo               = "rancher-charts"
  namespace          = "istio-system"
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
    time_sleep.rancher-monitoring-ready
  ]
}
