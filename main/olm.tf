/**
 * File: /main/olm.tf
 * Project: kops
 * File Created: 17-04-2022 06:13:18
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:09:17
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

module "olm-crds" {
  source             = "../modules/helm_release"
  enabled            = local.olm
  chart_name         = "olm-crds"
  chart_version      = "0.25.0"
  name               = "olm-crds"
  repo               = module.rock8s-repo.repo
  namespace          = "olm"
  rancher_project_id = local.rancher_project_id
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
EOF
  depends_on = [
    null_resource.wait-for-nodes
  ]
}

module "olm" {
  source             = "../modules/helm_release"
  enabled            = var.olm
  chart_name         = "olm"
  chart_version      = "0.25.0"
  name               = "olm"
  repo               = module.rock8s-repo.repo
  namespace          = "olm"
  rancher_project_id = local.rancher_project_id
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
EOF
  depends_on = [
    module.olm-crds
  ]
}
