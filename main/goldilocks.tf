/**
 * File: /main/goldilocks.tf
 * Project: kops
 * File Created: 20-04-2022 10:21:22
 * Author: Clay Risser
 * -----
 * Last Modified: 27-09-2022 12:37:14
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "goldilocks" {
  source           = "../modules/helm_release"
  chart_version    = "6.1.1"
  name             = "goldilocks"
  repo             = "https://charts.fairwinds.com/stable"
  chart_name       = "goldilocks"
  namespace        = "goldilocks"
  create_namespace = true
  values           = <<EOF
vpa:
  enabled: true
  updater:
    enabled: false
dashboard:
  excludeContainers: 'linkerd-proxy,istio-proxy'
EOF
  depends_on = [
    null_resource.wait_for_nodes
  ]
}
