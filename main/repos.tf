/**
 * File: /main/repos.tf
 * Project: kops
 * File Created: 21-04-2022 08:46:03
 * Author: Clay Risser
 * -----
 * Last Modified: 17-09-2022 06:55:25
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
    ignore_changes = [
      resource_version
    ]
  }
}

resource "rancher2_catalog_v2" "fluxcd" {
  cluster_id = local.rancher_cluster_id
  name       = "fluxcd"
  url        = "https://charts.fluxcd.io"
  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      resource_version
    ]
  }
}
