/**
 * File: /repos.tf
 * Project: main
 * File Created: 21-04-2022 08:46:03
 * Author: Clay Risser
 * -----
 * Last Modified: 20-05-2022 11:01:18
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "rancher2_catalog_v2" "risserlabs" {
  cluster_id = local.rancher_cluster_id
  url        = "https://risserlabs.gitlab.io/community/charts"
  name       = "risserlabs"
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "rancher2_catalog_v2" "fluxcd" {
  cluster_id = local.rancher_cluster_id
  name       = "fluxcd"
  url        = "https://charts.fluxcd.io"
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
