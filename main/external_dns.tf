/**
 * File: /external_dns.tf
 * Project: main
 * File Created: 21-04-2022 09:03:40
 * Author: Clay Risser
 * -----
 * Last Modified: 21-04-2022 11:34:04
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

# resource "rancher2_app_v2" "external_dns" {
#   chart_name    = "external-dns"
#   chart_version = "0.0.1"
#   cluster_id    = local.cluster_id
#   name          = "external-dns"
#   namespace     = rancher2_namespace.external_dns.name
#   repo_name     = rancher2_catalog_v2.bitspur.name
#   wait          = true
#   values        = <<EOF
# config:
#   target: '${local.cluster_name}.${var.domain}'
#   cloudflare:
#     apiKey: ${var.cloudflare_api_key}
#     email: ${var.cloudflare_email}
# EOF
#   depends_on = [
#     rancher2_app_v2.integration_operator
#   ]
#   lifecycle {
#     prevent_destroy = false
#     ignore_changes  = []
#   }
# }

# resource "rancher2_namespace" "external_dns" {
#   name       = "external-dns"
#   project_id = data.rancher2_project.system.id
#   lifecycle {
#     prevent_destroy = false
#     ignore_changes  = []
#   }
# }
