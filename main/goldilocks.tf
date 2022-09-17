/**
 * File: /main/goldilocks.tf
 * Project: kops
 * File Created: 20-04-2022 10:21:22
 * Author: Clay Risser
 * -----
 * Last Modified: 17-09-2022 06:55:25
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "helm_release" "goldilocks" {
  version          = "6.1.1"
  name             = "goldilocks"
  repository       = "https://charts.fairwinds.com/stable"
  chart            = "goldilocks"
  namespace        = "goldilocks"
  create_namespace = true
  values = [<<EOF
vpa:
  enabled: true
  updater:
    enabled: false
dashboard:
  excludeContainers: 'linkerd-proxy,istio-proxy'
EOF
  ]
  depends_on = [
    null_resource.wait_for_nodes
  ]
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
