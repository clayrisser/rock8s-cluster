/**
 * File: /main/olm.tf
 * Project: kops
 * File Created: 17-04-2022 06:13:18
 * Author: Clay Risser
 * -----
 * Last Modified: 29-09-2022 09:57:24
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "olm-crds" {
  source             = "../modules/helm_release"
  chart_name         = "olm-crds"
  chart_version      = "0.21.2"
  name               = "olm-crds"
  repo               = module.risserlabs_repo.repo
  namespace          = "olm"
  create_namespace   = true
  rancher_project_id = local.rancher_project_id
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
EOF
  depends_on         = []
}

module "olm" {
  source             = "../modules/helm_release"
  chart_name         = "olm"
  chart_version      = "0.21.2"
  name               = "olm"
  repo               = module.risserlabs_repo.repo
  namespace          = "olm"
  rancher_project_id = local.rancher_project_id
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
EOF
  depends_on = [
    module.olm-crds
  ]
}
