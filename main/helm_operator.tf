/**
 * File: /helm_operator.tf
 * Project: main
 * File Created: 07-05-2022 03:17:43
 * Author: Clay Risser
 * -----
 * Last Modified: 12-08-2022 12:34:05
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "rancher2_app_v2" "helm_operator" {
  chart_name    = "helm-operator"
  chart_version = "1.2.0"
  cluster_id    = local.rancher_cluster_id
  name          = "helm-operator"
  namespace     = "flux"
  repo_name     = rancher2_catalog_v2.fluxcd.name
  wait          = true
  values        = <<EOF
helm:
  versions: v3
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/arch
              operator: In
              values:
                - amd64
EOF
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
