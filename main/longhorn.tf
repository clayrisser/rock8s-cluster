/**
 * File: /main/longhorn.tf
 * Project: kops
 * File Created: 13-10-2022 02:34:15
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:09:12
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

module "longhorn" {
  source             = "../modules/helm_release"
  enabled            = local.longhorn
  chart_name         = "longhorn"
  chart_version      = "100.2.2+up1.3.1"
  name               = "longhorn"
  repo               = "rancher-charts"
  namespace          = "longhorn-system"
  rancher_project_id = local.rancher_project_id
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
EOF
  depends_on = [
    null_resource.wait-for-nodes
  ]
}
