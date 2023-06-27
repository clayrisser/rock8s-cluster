/**
 * File: /main/reloader.tf
 * Project: kops
 * File Created: 21-04-2022 08:39:20
 * Author: Clay Risser
 * -----
 * Last Modified: 27-06-2023 15:39:42
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

module "reloader" {
  source           = "../modules/helm_release"
  enabled          = var.reloader
  chart_name       = "reloader"
  chart_version    = "1.0.27"
  name             = "reloader"
  repo             = "https://stakater.github.io/stakater-charts"
  create_namespace = true
  namespace        = "reloader"
  values           = <<EOF
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
  depends_on = [
    null_resource.wait_for_nodes
  ]
}
