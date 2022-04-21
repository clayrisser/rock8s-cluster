/**
 * File: /repos.tf
 * Project: main
 * File Created: 21-04-2022 08:46:03
 * Author: Clay Risser
 * -----
 * Last Modified: 21-04-2022 09:48:07
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "rancher2_catalog_v2" "bitspur" {
  cluster_id = local.cluster_id
  url        = "https://bitspur.gitlab.io/community/charts"
  name       = "bitspur"
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
