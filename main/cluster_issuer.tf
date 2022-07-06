/**
 * File: /cluster_issuer.tf
 * Project: main
 * File Created: 07-05-2022 03:17:43
 * Author: Clay Risser
 * -----
 * Last Modified: 06-07-2022 06:38:39
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "rancher2_app_v2" "cluster_issuer" {
  chart_name    = "cluster-issuer"
  chart_version = "1.1.0"
  cluster_id    = local.rancher_cluster_id
  name          = "cluster-issuer"
  namespace     = "cert-manager"
  repo_name     = rancher2_catalog_v2.risserlabs.name
  wait          = true
  values        = <<EOF
config:
  cloudflareApiKey: '${var.cloudflare_api_key}'
  clusterType: rke
  email: ${var.cloudflare_email}
EOF
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
