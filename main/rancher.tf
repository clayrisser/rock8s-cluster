/**
 * File: /main.tf
 * Project: eks
 * File Created: 09-02-2022 11:24:10
 * Author: Clay Risser
 * -----
 * Last Modified: 14-04-2022 08:20:41
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

# locals {
#   cert_manager_letsencrypt_email       = "clayrisser@gmail.com"
#   cert_manager_letsencrypt_environment = "production"
#   rancher_admin_password               = var.rancher_admin_password
#   rancher_namespace                    = "cattle-system"
#   rancher_version                      = "v2.6.3"
#   rancher_hostname                     = var.rancher_hostname != "" ? var.rancher_hostname : data.kubernetes_service.ingress_nginx_controller.status.0.load_balancer.0.ingress.0.hostname
# }

# provider "rancher2" {
#   alias     = "bootstrap"
#   bootstrap = true
#   api_url   = "https://${local.rancher_hostname}"
# }

# resource "helm_release" "rancher" {
#   name             = "rancher"
#   repository       = "https://releases.rancher.com/server-charts/latest"
#   chart            = "rancher"
#   version          = local.rancher_version
#   namespace        = local.rancher_namespace
#   create_namespace = true
#   values = [<<EOF
# hostname: ${local.rancher_hostname}
# ingress:
#   enabled: true
#   extraAnnotations:
#     kubernetes.io/ingress.class: nginx
#   tls:
#     source: letsEncrypt
# letsEncrypt:
#   enabled: true
#   email: ${local.cert_manager_letsencrypt_email}
#   environment: ${local.cert_manager_letsencrypt_environment}
# EOF
#   ]
#   set {
#     name  = "helmVersion"
#     value = "v3"
#   }
#   depends_on = [
#     time_sleep.wait_for_ingress_nginx
#   ]
# }

# # resource "rancher2_bootstrap" "admin" {
# #   depends_on = [helm_release.rancher]
# #   provider   = rancher2.bootstrap
# #   password   = var.rancher_admin_password
# #   telemetry  = true
# # }

# provider "rancher2" {
#   alias     = "admin"
#   api_url   = rancher2_bootstrap.admin.url
#   token_key = var.rancher_token != "" ? var.rancher_token : rancher2_bootstrap.admin.token
# }
