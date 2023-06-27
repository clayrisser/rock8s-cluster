/**
 * File: /main/cluster_issuer.tf
 * Project: kops
 * File Created: 07-05-2022 03:17:43
 * Author: Clay Risser
 * -----
 * Last Modified: 27-06-2023 15:39:42
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

module "cluster_issuer" {
  source             = "../modules/helm_release"
  enabled            = var.cluster_issuer
  chart_name         = "cluster-issuer"
  chart_version      = "1.1.0"
  name               = "cluster-issuer"
  namespace          = "kube-system"
  repo               = module.rock8s_repo.repo
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
config:
  cloudflareApiKey: '${var.cloudflare_api_key}'
  clusterType: rke
  email: ${var.cloudflare_email}
EOF
  depends_on = [
    module.integration_operator
  ]
}

resource "kubectl_manifest" "cert_manager_default_issuer" {
  count     = (var.cluster_issuer && var.patch_operator) ? 1 : 0
  yaml_body = <<EOF
apiVersion: patch.rock8s.com/v1alpha1
kind: Patch
metadata:
  name: cert-manager-default-issuer
  namespace: kube-system
spec:
  patches:
    - id: cloud-credentials
      type: json
      waitForResource: true
      target:
        apiVersion: apps/v1
        kind: Deployment
        name: cert-manager
      patch: |
        - op: replace
          path: /spec/template/spec/containers/0/args
          value:
            - --v=2
            - --cluster-resource-namespace=\$(POD_NAMESPACE)
            - --leader-election-namespace=kube-system
            - --enable-certificate-owner-ref=true
            - --default-issuer-name=letsencrypt-cloudflare-prod
            - --default-issuer-kind=ClusterIssuer
            - --default-issuer-group=cert-manager.io
EOF
  depends_on = [
    module.cluster_issuer
  ]
  lifecycle {
    prevent_destroy = false
  }
}
