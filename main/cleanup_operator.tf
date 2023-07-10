/**
 * File: /main/cleanup_operator.tf
 * Project: kops
 * File Created: 12-02-2022 12:16:54
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:04:51
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

resource "helm_release" "cleanup-operator" {
  count            = var.cleanup_operator ? 1 : 0
  version          = "1.0.4"
  name             = "cleanup-operator"
  repository       = "https://charts.lwolf.org"
  chart            = "kube-cleanup-operator"
  namespace        = "kube-system"
  create_namespace = false
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
    null_resource.wait-for-nodes
  ]
  lifecycle {
    prevent_destroy = false
  }
}
