/**
 * File: /main/kubed.tf
 * Project: kops
 * File Created: 15-04-2022 14:48:11
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:08:00
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

resource "helm_release" "kubed" {
  count            = var.kubed ? 1 : 0
  name             = "kubed"
  version          = "v0.13.2"
  repository       = "https://charts.appscode.com/stable"
  chart            = "kubed"
  namespace        = "kube-system"
  create_namespace = true
  values = [<<EOF
EOF
  ]
  depends_on = [
    null_resource.wait-for-nodes
  ]
  lifecycle {
    prevent_destroy = false
  }
}
