/**
 * File: /main/external_dns.tf
 * Project: kops
 * File Created: 21-04-2022 09:03:40
 * Author: Clay Risser
 * -----
 * Last Modified: 18-09-2022 06:07:13
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "rancher2_app_v2" "external_dns" {
  chart_name    = "external-dns"
  chart_version = "0.0.1"
  cluster_id    = local.rancher_cluster_id
  name          = "external-dns"
  namespace     = rancher2_namespace.external_dns.name
  repo_name     = rancher2_catalog_v2.risserlabs.name
  wait          = true
  values        = <<EOF
config:
  target: '${local.cluster_entrypoint}'
  cloudflare:
    apiKey: ${var.cloudflare_api_key}
    email: ${var.cloudflare_email}
resources:
  limits:
    cpu: 50m
    memory: 25Mi
  requests:
    cpu: 10m
    memory: 25Mi
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

resource "rancher2_namespace" "external_dns" {
  name       = "external-dns"
  project_id = data.rancher2_project.system.id
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
