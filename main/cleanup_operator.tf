/**
 * File: /cleanup_operator.tf
 * Project: eks
 * File Created: 12-02-2022 12:16:54
 * Author: Clay Risser
 * -----
 * Last Modified: 17-09-2022 06:39:22
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "helm_release" "cleanup_operator" {
  version          = "1.0.3"
  name             = "cleanup-operator"
  repository       = "https://charts.lwolf.org"
  chart            = "kube-cleanup-operator"
  namespace        = "kube-system"
  create_namespace = true
  values = [<<EOF
args:
  - --delete-successful-after=5m
  - --delete-failed-after=120m
  - --delete-pending-pods-after=60m
  - --delete-evicted-pods-after=60m
  - --delete-orphaned-pods-after=60m
  - --legacy-mode=false
resources:
 limits:
   cpu: 50m
   memory: 64Mi
 requests:
   cpu: 10m
   memory: 32Mi
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
