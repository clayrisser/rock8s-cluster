/**
 * File: /main/longhorn.tf
 * Project: kops
 * File Created: 13-10-2022 02:34:15
 * Author: Clay Risser
 * -----
 * Last Modified: 14-10-2022 02:17:02
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "rancher_monitoring" {
  source             = "../modules/helm_release"
  enabled            = local.longhorn
  chart_name         = "longhorn"
  chart_version      = "100.2.2+up1.3.1"
  name               = "longhorn"
  repo               = "rancher-charts"
  namespace          = "longhorn-system"
  create_namespace   = true
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
EOF
}
