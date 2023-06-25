/**
 * File: /main/easy_olm_operator.tf
 * Project: kops
 * File Created: 21-04-2022 09:05:39
 * Author: Clay Risser
 * -----
 * Last Modified: 25-06-2023 09:37:41
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "easy_olm_operator" {
  source             = "../modules/helm_release"
  enabled            = local.integration_operator
  chart_name         = "easy-olm-operator"
  chart_version      = "0.0.1"
  name               = "easy-olm-operator"
  namespace          = "kube-system"
  repo               = module.bitspur_repo.repo
  rancher_cluster_id = local.rancher_cluster_id
  depends_on = [
    kubernetes_secret.registry,
    module.olm
  ]
}
