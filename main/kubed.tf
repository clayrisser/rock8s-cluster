/**
 * File: /main/kubed.tf
 * Project: kops
 * File Created: 15-04-2022 14:48:11
 * Author: Clay Risser
 * -----
 * Last Modified: 27-06-2023 15:39:42
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

module "kubed" {
  source           = "../modules/helm_release"
  enabled          = var.kubed
  chart_version    = "v0.13.2"
  name             = "kubed"
  repo             = "https://charts.appscode.com/stable"
  chart_name       = "kubed"
  namespace        = "kube-system"
  create_namespace = true
  depends_on = [
    null_resource.wait_for_nodes
  ]
}
