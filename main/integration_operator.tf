/**
 * File: /main/integration_operator.tf
 * Project: kops
 * File Created: 21-04-2022 09:05:39
 * Author: Clay Risser
 * -----
 * Last Modified: 27-09-2022 12:44:46
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "integration_operator" {
  source             = "../modules/helm_release"
  chart_name         = "integration-operator"
  chart_version      = "0.1.2"
  name               = "integration-operator"
  namespace          = "kube-system"
  repo               = rancher2_catalog_v2.risserlabs.name
  rancher_cluster_id = local.rancher_cluster_id
  depends_on = [
    module.patch_operator,
    kubernetes_secret.registry
  ]
}
