/**
 * File: /kubed.tf
 * Project: main
 * File Created: 15-04-2022 14:48:11
 * Author: Clay Risser
 * -----
 * Last Modified: 29-04-2022 17:41:20
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
}
