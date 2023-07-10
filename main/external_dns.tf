/**
 * File: /main/external_dns.tf
 * Project: kops
 * File Created: 21-04-2022 09:03:40
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:05:35
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

module "external-dns" {
  source             = "../modules/helm_release"
  enabled            = local.external_dns
  name               = "external-dns"
  repo               = module.rock8s-repo.repo
  chart_name         = "external-dns"
  chart_version      = "6.20.4"
  namespace          = "external-dns"
  rancher_project_id = local.rancher_project_id
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
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
    module.integration-operator,
    kubectl_manifest.flux-install
  ]
}
