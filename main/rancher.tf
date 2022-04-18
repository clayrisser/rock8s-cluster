/**
 * File: /rancher.tf
 * Project: eks
 * File Created: 09-02-2022 11:24:10
 * Author: Clay Risser
 * -----
 * Last Modified: 18-04-2022 12:37:03
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

locals {
  cert_manager_letsencrypt_email       = var.cloudflare_email
  cert_manager_letsencrypt_environment = "production"
  rancher_namespace                    = "cattle-system"
  rancher_version                      = "v2.6.3"
  rancher_hostname                     = "${local.cluster_name}.${var.domain}"
}

provider "rancher2" {
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

resource "null_resource" "bootstrap_rancher" {
  provisioner "local-exec" {
    command     = <<EOF
while ! curl -k $RANCHER_BASE_URL/ping >/dev/null; do sleep 3; done
BOOTSTRAP_PASSWORD=$(kubectl --kubeconfig <(echo $KUBECONFIG) get secret \
  --namespace cattle-system bootstrap-secret \
  -o go-template='{{.data.bootstrapPassword|base64decode}}{{"\n"}}')
TOKEN=$(curl -s "$RANCHER_BASE_URL/v3-public/localProviders/local?action=login" \
  -H 'content-type: application/json' \
  --data-binary '{"username":"admin","password":"'"$BOOTSTRAP_PASSWORD"'","ttl":60000}' \
  --insecure | jq -r .token)
curl "$RANCHER_BASE_URL/v3/users?action=changepassword" \
  -H 'content-type: application/json' \
  -H "Authorization: Bearer $TOKEN" \
  --data-binary '{"currentPassword":"'"$BOOTSTRAP_PASSWORD"'","newPassword":"'"$RANCHER_ADMIN_PASSWORD"'"}' \
  --insecure >/dev/null
curl "$RANCHER_BASE_URL/v3/settings/server-url" \
  -H 'content-type: application/json' \
  -H "Authorization: Bearer $TOKEN" \
  -X PUT \
  --data-binary '{"name":"server-url","value":"'"$RANCHER_BASE_URL"'"}' \
  --insecure >/dev/null
EOF
    interpreter = ["sh", "-c"]
    environment = {
      KUBECONFIG             = local.kubeconfig
      RANCHER_ADMIN_PASSWORD = var.rancher_admin_password
      RANCHER_BASE_URL       = "https://${local.rancher_hostname}"
    }
  }
  depends_on = [
    module.eks
  ]
}
