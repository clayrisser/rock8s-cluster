/**
 * File: /main/patch_operator.tf
 * Project: kops
 * File Created: 21-04-2022 08:58:02
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:07:01
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

resource "helm_release" "patch-operator" {
  name             = "patch-operator"
  version          = "0.1.0"
  repository       = "https://charts.rock8s.com"
  chart            = "patch-operator"
  namespace        = "rock8s-system"
  create_namespace = true
  values = [<<EOF
EOF
  ]
  depends_on = [
    kubectl_manifest.rock8s-cluster-info
  ]
  lifecycle {
    prevent_destroy = false
  }
}
