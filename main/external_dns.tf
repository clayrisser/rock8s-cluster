/**
 * File: /main/external_dns.tf
 * Project: kops
 * File Created: 21-04-2022 09:03:40
 * Author: Clay Risser
 * -----
 * Last Modified: 29-09-2022 05:35:49
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "external_dns" {
  source             = "../modules/helm_release"
  name               = "external-dns"
  repo               = module.risserlabs_repo.repo
  chart_name         = "external-dns"
  chart_version      = "0.0.1"
  namespace          = "external-dns"
  create_namespace   = true
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
    module.integration_operator,
    module.helm_operator
  ]
}
