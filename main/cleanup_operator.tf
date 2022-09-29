/**
 * File: /main/cleanup_operator.tf
 * Project: kops
 * File Created: 12-02-2022 12:16:54
 * Author: Clay Risser
 * -----
 * Last Modified: 29-09-2022 09:49:07
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "cleanup_operator" {
  source        = "../modules/helm_release"
  enabled       = var.cleanup_operator
  chart_version = "1.0.3"
  name          = "cleanup-operator"
  repo          = "https://charts.lwolf.org"
  chart_name    = "kube-cleanup-operator"
  namespace     = "kube-system"
  values        = <<EOF
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
  depends_on = [
    null_resource.wait_for_nodes
  ]
}
