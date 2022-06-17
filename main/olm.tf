/**
 * File: /olm.tf
 * Project: main
 * File Created: 17-04-2022 06:13:18
 * Author: Clay Risser
 * -----
 * Last Modified: 11-06-2022 09:43:51
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

locals {
  olm_version = "v0.21.2"
}

resource "rancher2_app_v2" "olm" {
  chart_name    = "olm"
  chart_version = "0.21.2"
  cluster_id    = local.rancher_cluster_id
  name          = "olm"
  namespace     = "olm"
  repo_name     = rancher2_catalog_v2.risserlabs.name
  wait          = true
  values        = <<EOF
EOF
  depends_on    = []
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
