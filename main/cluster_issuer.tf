/**
 * File: /main/cluster_issuer.tf
 * Project: kops
 * File Created: 07-05-2022 03:17:43
 * Author: Clay Risser
 * -----
 * Last Modified: 29-09-2022 12:41:23
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "cluster_issuer" {
  source             = "../modules/helm_release"
  enabled            = var.cluster_issuer
  chart_name         = "cluster-issuer"
  chart_version      = "1.1.0"
  name               = "cluster-issuer"
  namespace          = "kube-system"
  repo               = module.risserlabs_repo.repo
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
