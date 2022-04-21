/**
 * File: /calico.tf
 * Project: main
 * File Created: 21-04-2022 14:31:26
 * Author: Clay Risser
 * -----
 * Last Modified: 21-04-2022 14:33:35
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */


locals {
  calico_version = "v3.21.4"
}

resource "helm_release" "calico" {
  version    = local.calico_version
  name       = "calico"
  repository = "https://docs.projectcalico.org/charts"
  chart      = "tigera-operator"
  values = [<<EOF
{}
EOF
  ]
  depends_on = [
    null_resource.wait_for_nodes
  ]
}
