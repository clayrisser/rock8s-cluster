/**
 * File: /main/helm_controller.tf
 * Project: kops
 * File Created: 07-05-2022 03:17:43
 * Author: Clay Risser
 * -----
 * Last Modified: 27-09-2022 13:36:33
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "helm_controller" {
  source             = "../modules/helm_release"
  chart_name         = "helm-controller"
  chart_version      = "0.12.3"
  name               = "helm-controller"
  namespace          = "kube-system"
  repo               = module.risserlabs_repo.repo
  rancher_cluster_id = local.rancher_cluster_id
}
