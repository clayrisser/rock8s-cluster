/**
 * File: /main/easy_olm_operator.tf
 * Project: kops
 * File Created: 21-04-2022 09:05:39
 * Author: Clay Risser
 * -----
 * Last Modified: 27-06-2023 15:39:42
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

module "easy_olm_operator" {
  source             = "../modules/helm_release"
  enabled            = local.integration_operator
  chart_name         = "easy-olm-operator"
  chart_version      = "0.0.1"
  name               = "easy-olm-operator"
  namespace          = "kube-system"
  repo               = module.rock8s_repo.repo
  rancher_cluster_id = local.rancher_cluster_id
  depends_on = [
    kubernetes_secret.registry,
    module.olm
  ]
}
