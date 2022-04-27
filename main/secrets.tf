/**
 * File: /secrets.tf
 * Project: main
 * File Created: 27-04-2022 12:01:36
 * Author: Clay Risser
 * -----
 * Last Modified: 27-04-2022 12:55:46
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
    common_name  = local.cluster_name
    organization = local.cluster_name
    country      = "US"
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

resource "tls_private_key" "node" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "node" {
  key_name   = "nodes.${local.cluster_name}"
  public_key = tls_private_key.node.public_key_openssh
}
