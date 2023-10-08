/**
 * File: /tls.tf
 * Project: main
 * File Created: 27-09-2023 05:26:35
 * Author: Clay Risser
 * -----
 * BitSpur (c) Copyright 2021 - 2023
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
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
  validity_period_hours = 867240 # 99 years
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

resource "local_file" "admin-rsa" {
  content  = tls_private_key.admin.private_key_openssh
  filename = "${path.module}/artifacts/admin_rsa"
}

resource "local_file" "admin-rsa-pub" {
  content  = tls_private_key.admin.public_key_openssh
  filename = "${path.module}/artifacts/admin_rsa.pub"
}

resource "local_file" "node-rsa" {
  content  = tls_private_key.node.private_key_openssh
  filename = "${path.module}/artifacts/node_rsa"
}

resource "local_file" "node-rsa-pub" {
  content  = tls_private_key.node.public_key_openssh
  filename = "${path.module}/artifacts/node_rsa.pub"
}
