/**
 * File: /main/patch_operator.tf
 * Project: kops
 * File Created: 21-04-2022 08:58:02
 * Author: Clay Risser
 * -----
 * Last Modified: 27-09-2022 13:36:33
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "patch_operator" {
  source             = "../modules/helm_release"
  chart_name         = "patch-operator"
  chart_version      = "0.1.0"
  name               = "patch-operator"
  repo               = module.risserlabs_repo.repo
  namespace          = "kube-system"
  rancher_cluster_id = local.rancher_cluster_id
}
