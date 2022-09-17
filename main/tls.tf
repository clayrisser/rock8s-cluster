/**
 * File: /main/tls.tf
 * Project: kops
 * File Created: 27-04-2022 12:01:36
 * Author: Clay Risser
 * -----
 * Last Modified: 17-09-2022 06:55:25
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem   = tls_private_key.ca.private_key_pem
  is_ca_certificate = true
  subject {
    common_name = "ca.${local.cluster_name}"
  }
  validity_period_hours = 43800
  allowed_uses = [
    "client_auth",
    "digital_signature",
    "key_encipherment",
    "server_auth"
  ]
}

resource "tls_private_key" "admin" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "admin_rsa" {
  content  = tls_private_key.admin.private_key_openssh
  filename = "${path.module}/../artifacts/admin_rsa"
}

resource "local_file" "admin_rsa_pub" {
  content  = tls_private_key.admin.public_key_openssh
  filename = "${path.module}/../artifacts/admin_rsa.pub"
}

resource "local_file" "node_rsa" {
  content  = tls_private_key.node.private_key_openssh
  filename = "${path.module}/../artifacts/node_rsa"
}

resource "local_file" "node_rsa_pub" {
  content  = tls_private_key.node.public_key_openssh
  filename = "${path.module}/../artifacts/node_rsa.pub"
}

resource "tls_private_key" "node" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
