/**
 * File: /modules/helm_repo/main.tf
 * Project: kops
 * File Created: 27-09-2022 10:24:31
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:09:05
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

locals {
  is_rancher = var.rancher_cluster_id != ""
}

resource "rancher2_catalog_v2" "this" {
  count      = local.is_rancher ? 1 : 0
  cluster_id = var.rancher_cluster_id
  name       = var.name
  url        = var.url
  lifecycle {
    prevent_destroy = false
  }
}
