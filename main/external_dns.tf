/**
 * File: /external_dns.tf
 * Project: main
 * File Created: 21-04-2022 09:03:40
 * Author: Clay Risser
 * -----
 * Last Modified: 20-05-2022 10:58:51
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "rancher2_app_v2" "external_dns" {
  chart_name    = "external-dns"
  chart_version = "0.0.1"
  cluster_id    = local.rancher_cluster_id
  name          = "external-dns"
  namespace     = "external-dns"
  repo_name     = rancher2_catalog_v2.risserlabs.name
  wait          = true
  values        = <<EOF
config:
  target: '${local.cluster_entrypoint}'
  cloudflare:
    apiKey: ${var.cloudflare_api_key}
    email: ${var.cloudflare_email}
EOF
  depends_on = [
    rancher2_app_v2.integration_operator,
    rancher2_app_v2.helm_operator
  ]
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
