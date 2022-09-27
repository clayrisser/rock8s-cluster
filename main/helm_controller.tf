/**
 * File: /main/helm_controller.tf
 * Project: kops
 * File Created: 07-05-2022 03:17:43
 * Author: Clay Risser
 * -----
 * Last Modified: 27-09-2022 12:44:02
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
  repo               = rancher2_catalog_v2.risserlabs.name
  rancher_cluster_id = local.rancher_cluster_id
}
