/**
 * File: /tls.tf
 * Project: main
 * File Created: 27-04-2022 12:01:36
 * Author: Clay Risser
 * -----
 * Last Modified: 18-07-2022 14:17:21
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
    common_name = "kubernetes-ca-ca"
  }
  validity_period_hours = 43800
  allowed_uses = [
    "client_auth",
    "digital_signature",
    "key_encipherment",
    "server_auth"
  ]
}

resource "tls_private_key" "root_ca" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "root_ca" {
  private_key_pem   = tls_private_key.root_ca.private_key_pem
  is_ca_certificate = true
  subject {
    common_name = "kubernetes-ca-root"
  }
  validity_period_hours = 43800
  allowed_uses = [
    "client_auth",
    "digital_signature",
    "key_encipherment",
    "server_auth"
  ]
}

resource "tls_private_key" "client_ca" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "client_ca" {
  private_key_pem   = tls_private_key.client_ca.private_key_pem
  is_ca_certificate = true
  subject {
    common_name = "kubernetes-ca-client"
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
