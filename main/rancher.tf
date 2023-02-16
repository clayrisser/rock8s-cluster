/**
 * File: /main/rancher.tf
 * Project: kops
 * File Created: 09-02-2022 11:24:10
 * Author: Clay Risser
 * -----
 * Last Modified: 16-02-2023 02:38:55
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

locals {
  cert_manager_letsencrypt_email       = var.cloudflare_email
  cert_manager_letsencrypt_environment = "production"
  rancher_bootstrap_password           = "rancherP@ssw0rd"
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
  version          = "v2.7.1"
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
    cpu: 2
    memory: 2Gi
  requests:
    cpu: 1.5
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

resource "kubectl_manifest" "rancher_patch" {
  count     = (var.logging && local.rancher) ? 1 : 0
  yaml_body = <<EOF
apiVersion: patch.risserlabs.com/v1alpha1
kind: Patch
metadata:
  name: rancher
  namespace: cattle-system
spec:
  patches:
    - id: rancher
      target:
        group: apps
        version: v1
        kind: Deployment
        name: rancher
      waitForTimeout: 5
      waitForResource: true
      type: json
      patch: |
        - op: replace
          path: /spec/template/spec/tolerations
          value:
            - key: cattle.io/os
              value: linux
              effect: NoSchedule
              operator: Equal
            - key: node-role.kubernetes.io/master
              effect: NoSchedule
              operator: Exists
        - op: add
          path: /spec/template/spec/affinity/nodeAffinity
          value:
            requiredDuringSchedulingIgnoredDuringExecution:
              nodeSelectorTerms:
                - matchExpressions:
                    - key: node-role.kubernetes.io/master
                      operator: Exists
        - op: remove
          path: /spec/strategy/rollingUpdate
        - op: replace
          path: /spec/strategy/type
          value: Recreate
EOF
  depends_on = [
    helm_release.rancher,
    helm_release.patch_operator,
  ]
  lifecycle {
    prevent_destroy = false
  }
}

resource "null_resource" "wait_for_rancher" {
  count = local.rancher ? 1 : 0
  provisioner "local-exec" {
    command     = <<EOF
while [ ! "$(kubectl --kubeconfig <(echo $KUBECONFIG) get patches.patch.risserlabs.com -n cattle-system rancher -o json | jq -r '.status.phase')" = "Succeeded" ]; do
  sleep 10
done
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
      KUBECONFIG       = local.kubeconfig
    }
  }
  depends_on = [
    kubectl_manifest.rancher_patch
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
