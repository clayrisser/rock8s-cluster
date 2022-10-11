/**
 * File: /main/rancher.tf
 * Project: kops
 * File Created: 09-02-2022 11:24:10
 * Author: Clay Risser
 * -----
 * Last Modified: 11-10-2022 08:10:42
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

locals {
  cert_manager_letsencrypt_email       = var.cloudflare_email
  cert_manager_letsencrypt_environment = "production"
  rancher_bootstrap_password           = "P@ssw0rd"
  rancher_hostname                     = length(aws_route53_record.cluster) > 0 ? aws_route53_record.cluster[0].name : "localhost"
}

provider "rancher2" {
  alias     = "bootstrap"
  bootstrap = true
  insecure  = true
  api_url   = "https://${local.rancher_hostname}"
}

resource "helm_release" "rancher" {
  count            = local.rancher ? 1 : 0
  name             = "rancher"
  repository       = "https://releases.rancher.com/server-charts/latest"
  chart            = "rancher"
  version          = "v2.6.8"
  namespace        = "cattle-system"
  create_namespace = true
  values = [<<EOF
replicas: 1
bootstrapPassword: ${local.rancher_bootstrap_password}
hostname: ${local.rancher_hostname}
ingress:
  enabled: true
  extraAnnotations:
    kubernetes.io/ingress.class: nginx
  tls:
    source: letsEncrypt
letsEncrypt:
  enabled: true
  email: ${local.cert_manager_letsencrypt_email}
  environment: ${local.cert_manager_letsencrypt_environment}
resources:
  limits:
    cpu: 1500m
    memory: 2Gi
  requests:
    cpu: 1
    memory: 1.5Gi
EOF
  ]
  set {
    name  = "helmVersion"
    value = "v3"
  }
  depends_on = [
    null_resource.wait_for_ingress_nginx
  ]
}

resource "null_resource" "wait_for_rancher" {
  count = local.rancher ? 1 : 0
  provisioner "local-exec" {
    command     = <<EOF
while [ "$${subject}" != "*  subject: CN=$RANCHER_HOSTNAME" ]; do
    subject=$(curl -vk -m 2 "https://$RANCHER_HOSTNAME/ping" 2>&1 | grep "subject:")
    echo "Cert Subject Response: $${subject}"
    if [ "$${subject}" != "*  subject: CN=$RANCHER_HOSTNAME" ]; then
      sleep 10
    fi
done
while [ "$${resp}" != "pong" ]; do
    resp=$(curl -sSk -m 2 "https://$RANCHER_HOSTNAME/ping")
    echo "Rancher Response: $${resp}"
    if [ "$${resp}" != "pong" ]; then
      sleep 10
    fi
done
EOF
    interpreter = ["sh", "-c"]
    environment = {
      RANCHER_HOSTNAME = local.rancher_hostname
    }
  }
  depends_on = [
    helm_release.rancher[0]
  ]
}

resource "rancher2_bootstrap" "admin" {
  count            = local.rancher ? 1 : 0
  provider         = rancher2.bootstrap
  initial_password = local.rancher_bootstrap_password
  password         = var.rancher_admin_password
  telemetry        = true
  depends_on = [
    null_resource.wait_for_rancher[0]
  ]
}

provider "rancher2" {
  alias     = "admin"
  api_url   = "https://${local.rancher_hostname}"
  token_key = length(rancher2_bootstrap.admin) > 0 ? rancher2_bootstrap.admin[0].token : ""
}

resource "rancher2_token" "this" {
  count       = local.rancher ? 1 : 0
  provider    = rancher2.admin
  description = "terraform"
  depends_on = [
    null_resource.wait_for_rancher[0]
  ]
}

provider "rancher2" {
  api_url   = "https://${local.rancher_hostname}"
  token_key = length(rancher2_token.this) > 0 ? rancher2_token.this[0].token : ""
}

data "rancher2_project" "system" {
  count      = local.rancher ? 1 : 0
  cluster_id = local.rancher_cluster_id
  name       = "System"
  depends_on = [
    rancher2_token.this[0]
  ]
}
