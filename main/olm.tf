/**
 * File: /olm.tf
 * Project: main
 * File Created: 17-04-2022 06:13:18
 * Author: Clay Risser
 * -----
 * Last Modified: 17-04-2022 06:24:35
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "olm" {
  source     = "streamnative/charts/helm"
  version    = "0.8.1"
  enable_olm = true
  depends_on = [
    null_resource.wait_for_nodes
  ]
}
