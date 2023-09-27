/**
 * File: /variables.tf
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

variable "public_api_ports" {
  default = "22,443"
}

variable "public_nodes_ports" {
  default = "22,80,443"
}

variable "region" {
  default = "us-east-2"
}

variable "cluster_prefix" {
  default = "kops"
}

variable "iteration" {
  default = 0
}

variable "rancher_admin_password" {
  default = "rancherP@ssw0rd"
}

variable "main_bucket" {
  default = ""
}

variable "oidc_bucket" {
  default = ""
}

variable "tempo_bucket" {
  default = ""
}

variable "thanos_bucket" {
  default = ""
}

variable "loki_bucket" {
  default = ""
}

variable "api_strategy" {
  default = "LB"
  validation {
    condition     = contains(["DNS", "LB"], var.api_strategy)
    error_message = "Allowed values for entrypoint_strategy are \"DNS\" or \"LB\"."
  }
}

variable "dns_zone" {
  type = string
}

variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_access_key" {
  type = string
}

variable "letsencrypt_email" {
  type    = string
  default = "email@example.com"
}

variable "rancher" {
  type    = bool
  default = true
}

variable "cleanup_operator" {
  type    = bool
  default = true
}

variable "cluster_issuer" {
  type    = bool
  default = true
}

variable "external_dns" {
  type    = bool
  default = true
}

variable "flux" {
  type    = bool
  default = true
}

variable "argo" {
  type    = bool
  default = true
}

variable "kanister" {
  type    = bool
  default = true
}

variable "kubed" {
  type    = bool
  default = true
}

variable "logging" {
  type    = bool
  default = true
}

variable "ingress_nginx" {
  type    = bool
  default = true
}

variable "olm" {
  type    = bool
  default = true
}

variable "rancher_istio" {
  type    = bool
  default = true
}

variable "rancher_monitoring" {
  type    = bool
  default = true
}

variable "tempo" {
  type    = bool
  default = true
}

variable "efs_csi" {
  type    = bool
  default = true
}

variable "longhorn" {
  type    = bool
  default = false
}

variable "autoscaler" {
  type    = bool
  default = true
}

variable "reloader" {
  type    = bool
  default = true
}

variable "retention_hours" {
  type    = number
  default = 168
}

variable "ack_services" {
  default = "s3,iam,rds"
}

variable "ingress_ports" {
  default = "80,443"
}
