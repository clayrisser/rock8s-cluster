/**
 * File: /main/cluster_issuer.tf
 * Project: kops
 * File Created: 07-05-2022 03:17:43
 * Author: Clay Risser
 * -----
 * Last Modified: 27-09-2022 12:37:05
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "cluster_issuer" {
  source             = "../modules/helm_release"
  chart_name         = "cluster-issuer"
  chart_version      = "1.1.0"
  name               = "cluster-issuer"
  namespace          = "kube-system"
  repo               = rancher2_catalog_v2.risserlabs.name
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
config:
  cloudflareApiKey: '${var.cloudflare_api_key}'
  clusterType: rke
  email: ${var.cloudflare_email}
EOF
  depends_on = [
    module.integration_operator
  ]
}
