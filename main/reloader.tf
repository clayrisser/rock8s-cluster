/**
 * File: /main/reloader.tf
 * Project: kops
 * File Created: 21-04-2022 08:39:20
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:08:45
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

resource "helm_release" "reloader" {
  count            = var.reloader ? 1 : 0
  name             = "reloader"
  version          = "1.0.27"
  repository       = "https://stakater.github.io/stakater-charts"
  chart            = "reloader"
  namespace        = "reloader"
  create_namespace = true
  values = [<<EOF
reloader:
  ignoreSecrets: false
  ignoreConfigMaps: false
  reloadOnCreate: false
  reloadStrategy: default
  ignoreNamespaces: ""
  watchGlobally: true
  enableHA: false
  readOnlyRootFileSystem: false
EOF
  ]
  depends_on = [
    null_resource.wait-for-nodes
  ]
  lifecycle {
    prevent_destroy = false
  }
}
