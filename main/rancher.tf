/**
 * File: /rancher.tf
 * Project: eks
 * File Created: 09-02-2022 11:24:10
 * Author: Clay Risser
 * -----
 * Last Modified: 20-04-2022 05:54:17
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

locals {
  cert_manager_letsencrypt_email       = var.cloudflare_email
  cert_manager_letsencrypt_environment = "production"
  rancher_namespace                    = "cattle-system"
  rancher_version                      = "v2.6.4"
  rancher_hostname                     = "${local.cluster_name}.${var.domain}"
}

provider "rancher2" {
  alias     = "bootstrap"
  bootstrap = true
  api_url   = "https://${local.rancher_hostname}"
}

resource "helm_release" "rancher" {
  name             = "rancher"
  repository       = "https://releases.rancher.com/server-charts/latest"
  chart            = "rancher"
  version          = local.rancher_version
  namespace        = local.rancher_namespace
  create_namespace = true
  values = [<<EOF
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
EOF
  ]
  set {
    name  = "helmVersion"
    value = "v3"
  }
  depends_on = [
    helm_release.cert_manager,
    time_sleep.wait_for_ingress_nginx
  ]
}

resource "null_resource" "wait_for_rancher" {
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
    helm_release.rancher
  ]
}

resource "rancher2_bootstrap" "admin" {
  provider  = rancher2.bootstrap
  password  = var.rancher_admin_password
  telemetry = true
  depends_on = [
    null_resource.wait_for_rancher
  ]
}

provider "rancher2" {
  alias     = "admin"
  api_url   = rancher2_bootstrap.admin.url
  token_key = rancher2_bootstrap.admin.token
}

resource "rancher2_token" "this" {
  provider    = rancher2.admin
  description = "terraform"
  depends_on = [
    null_resource.wait_for_rancher
  ]
}

# resource "null_resource" "bootstrap_rancher" {
#   provisioner "local-exec" {
#     command     = <<EOF
# RANCHER_BASE_URL="https://$RANCHER_HOSTNAME"
# BOOTSTRAP_PASSWORD=$(kubectl --kubeconfig <(echo $KUBECONFIG) get secret \
#   --namespace cattle-system bootstrap-secret \
#   -o go-template='{{.data.bootstrapPassword|base64decode}}{{"\n"}}')
# TOKEN=$(curl -s "$RANCHER_BASE_URL/v3-public/localProviders/local?action=login" \
#   -H 'content-type: application/json' \
#   --data-binary '{"username":"admin","password":"'"$BOOTSTRAP_PASSWORD"'","ttl":60000}' \
#   --insecure | jq -r .token)
# curl "$RANCHER_BASE_URL/v3/users?action=changepassword" \
#   -H 'content-type: application/json' \
#   -H "Authorization: Bearer $TOKEN" \
#   --data-binary '{"currentPassword":"'"$BOOTSTRAP_PASSWORD"'","newPassword":"'"$RANCHER_ADMIN_PASSWORD"'"}' \
#   --insecure >/dev/null
# curl "$RANCHER_BASE_URL/v3/settings/server-url" \
#   -H 'content-type: application/json' \
#   -H "Authorization: Bearer $TOKEN" \
#   -X PUT \
#   --data-binary '{"name":"server-url","value":"'"$RANCHER_BASE_URL"'"}' \
#   --insecure >/dev/null
# EOF
#     interpreter = ["sh", "-c"]
#     environment = {
#       KUBECONFIG             = local.kubeconfig
#       RANCHER_ADMIN_PASSWORD = var.rancher_admin_password
#       RANCHER_HOSTNAME       = local.rancher_hostname
#     }
#   }
#   depends_on = [
#     null_resource.wait_for_rancher,
#     rancher2_token.this
#   ]
# }
