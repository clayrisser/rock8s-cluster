/**
 * File: /main/olm.tf
 * Project: kops
 * File Created: 17-04-2022 06:13:18
 * Author: Clay Risser
 * -----
 * Last Modified: 18-09-2022 06:07:01
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
  namespace     = rancher2_namespace.olm.name
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

resource "rancher2_namespace" "olm" {
  name       = "olm"
  project_id = data.rancher2_project.system.id
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
