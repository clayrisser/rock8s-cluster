/**
 * File: /main/helm_controller.tf
 * Project: kops
 * File Created: 07-05-2022 03:17:43
 * Author: Clay Risser
 * -----
 * Last Modified: 26-06-2023 07:20:39
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "helm_controller" {
  source             = "../modules/helm_release"
  enabled            = var.helm_controller
  chart_name         = "helm-controller"
  chart_version      = "0.12.3"
  name               = "helm-controller"
  namespace          = "kube-system"
  repo               = module.rock8s_repo.repo
  rancher_cluster_id = local.rancher_cluster_id
}
