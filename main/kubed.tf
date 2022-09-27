/**
 * File: /main/kubed.tf
 * Project: kops
 * File Created: 15-04-2022 14:48:11
 * Author: Clay Risser
 * -----
 * Last Modified: 27-09-2022 12:37:57
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "kubed" {
  source           = "../modules/helm_release"
  chart_version    = "v0.13.0"
  name             = "kubed"
  repo             = "https://charts.appscode.com/stable"
  chart_name       = "kubed"
  namespace        = "kube-system"
  create_namespace = true
  depends_on = [
    null_resource.wait_for_nodes
  ]
}
