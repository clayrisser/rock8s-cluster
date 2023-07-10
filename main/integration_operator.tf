/**
 * File: /main/integration_operator.tf
 * Project: kops
 * File Created: 21-04-2022 09:05:39
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:06:10
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

module "integration-operator" {
  source             = "../modules/helm_release"
  enabled            = local.integration_operator
  chart_name         = "integration-operator"
  chart_version      = "0.2.0"
  name               = "integration-operator"
  namespace          = "rock8s-system"
  repo               = module.rock8s-repo.repo
  rancher_project_id = local.rancher_project_id
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
EOF
  depends_on = [
    helm_release.patch-operator,
  ]
}
