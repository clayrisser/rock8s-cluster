/**
 * File: /main/goldilocks.tf
 * Project: kops
 * File Created: 20-04-2022 10:21:22
 * Author: Clay Risser
 * -----
 * Last Modified: 10-06-2023 13:31:25
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "goldilocks" {
  source             = "../modules/helm_release"
  enabled            = var.goldilocks
  chart_version      = "6.7.0"
  name               = "goldilocks"
  repo               = module.fairwinds_repo.repo
  chart_name         = "goldilocks"
  namespace          = "goldilocks"
  create_namespace   = true
  rancher_project_id = local.rancher_project_id
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
vpa:
  enabled: true
  updater:
    enabled: false
dashboard:
  excludeContainers: 'linkerd-proxy,istio-proxy'
EOF
  depends_on = [
    null_resource.wait_for_nodes
  ]
}
