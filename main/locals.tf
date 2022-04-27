/**
 * File: /locals.tf
 * Project: main
 * File Created: 14-04-2022 13:36:29
 * Author: Clay Risser
 * -----
 * Last Modified: 27-04-2022 14:30:02
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

locals {
  cluster_name         = "${var.cluster_prefix}-${tostring(var.iteration)}.${var.dns_zone}"
  bucket               = var.bucket == "" ? var.dns_zone : var.bucket
  kops_kubeconfig_file = "../kubeconfig"
  rancher_cluster_id   = "local"
  kops_state_store     = "s3://${local.bucket}/kops"
  public_api_ports     = [for port in split(",", var.public_api_ports) : parseint(port, 10)]
  public_nodes_ports   = [for port in split(",", var.public_nodes_ports) : parseint(port, 10)]
  k8s = {
    cluster_ca_certificate = tls_self_signed_cert.ca.cert_pem
    password               = "P@ssw0rd" // TODO: make more secure
    server                 = "https://api.${var.cluster_prefix}-${tostring(var.iteration)}.${var.dns_zone}"
    username               = "admin"
  }
  kubeconfig = jsonencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = "terraform"
      cluster = {
        certificate-authority-data = base64encode(local.k8s.cluster_ca_certificate)
        server                     = local.k8s.server
      }
    }]
    users = [{
      name = "terraform"
      user = {
        # client-certificate-data = base64encode(data.kops_kube_config.this.client_cert)
        # client-key-data         = base64encode(data.kops_kube_config.this.client_key)
        password = local.k8s.password
        username = local.k8s.username
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = "terraform"
        user    = "terraform"
      }
    }]
  })
}
