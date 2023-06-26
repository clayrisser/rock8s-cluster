/**
 * File: /main/integration_operator.tf
 * Project: kops
 * File Created: 21-04-2022 09:05:39
 * Author: Clay Risser
 * -----
 * Last Modified: 26-06-2023 07:20:39
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "integration_operator" {
  source             = "../modules/helm_release"
  enabled            = local.integration_operator
  chart_name         = "integration-operator"
  chart_version      = "0.1.2"
  name               = "integration-operator"
  namespace          = "kube-system"
  repo               = module.rock8s_repo.repo
  rancher_cluster_id = local.rancher_cluster_id
  depends_on = [
    helm_release.patch_operator,
    kubernetes_secret.registry
  ]
}
