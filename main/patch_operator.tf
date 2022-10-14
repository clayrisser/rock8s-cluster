/**
 * File: /main/patch_operator.tf
 * Project: kops
 * File Created: 21-04-2022 08:58:02
 * Author: Clay Risser
 * -----
 * Last Modified: 14-10-2022 10:57:41
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "helm_release" "patch_operator" {
  name       = "patch-operator"
  version    = "0.1.0"
  repository = "https://risserlabs.gitlab.io/community/charts"
  chart      = "patch-operator"
  namespace  = "kube-system"
  values = [<<EOF
EOF
  ]
  depends_on = [
    null_resource.wait_for_nodes
  ]
  lifecycle {
    prevent_destroy = false
  }
}
