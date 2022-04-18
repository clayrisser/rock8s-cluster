/**
 * File: /cert_manager.tf
 * Project: eks
 * File Created: 09-02-2022 11:17:38
 * Author: Clay Risser
 * -----
 * Last Modified: 15-04-2022 14:46:41
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

locals {
  cert_manager_version   = "v1.5.4"
  cert_manager_namespace = "cert-manager"
}

module "cert_manager_crds" {
  source    = "../modules/crds"
  name      = "cert-manager-${replace(local.cert_manager_version, "/[^v0-9]/", "-")}"
  namespace = "kube-system"
  crds = [
    "https://github.com/jetstack/cert-manager/releases/download/${local.cert_manager_version}/cert-manager.crds.yaml",
  ]
  depends_on = [
    null_resource.wait_for_nodes
  ]
}

resource "helm_release" "cert_manager" {
  version          = local.cert_manager_version
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = local.cert_manager_namespace
  create_namespace = true
  values = [<<EOF
{}
EOF
  ]
  depends_on = [
    module.cert_manager_crds,
  ]
}