/**
 * File: /main/kubed.tf
 * Project: kops
 * File Created: 15-04-2022 14:48:11
 * Author: Clay Risser
 * -----
 * Last Modified: 17-09-2022 06:55:25
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "helm_release" "kubed" {
  version          = "v0.13.0"
  name             = "kubed"
  repository       = "https://charts.appscode.com/stable"
  chart            = "kubed"
  namespace        = "kube-system"
  create_namespace = true
  values = [<<EOF
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
