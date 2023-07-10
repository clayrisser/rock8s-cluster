/**
 * File: /main/rock8s.tf
 * Project: kops
 * File Created: 05-07-2023 13:03:42
 * Author: Clay Risser
 * -----
 * Last Modified: 08-07-2023 15:12:49
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022 - 2023
 */

resource "kubernetes_namespace" "rock8s-global" {
  metadata {
    name = "rock8s-global"
  }
  depends_on = [
    null_resource.wait-for-nodes
  ]
  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

resource "kubectl_manifest" "rock8s-cluster-info" {
  yaml_body = <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-info
  namespace: ${kubernetes_namespace.rock8s-global.metadata[0].name}
data:
  clusterName: ${local.cluster_name}
EOF
}
