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
  default = "22,80,443,30000-32768"
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

variable "kanister_bucket" {
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

variable "rancher" {
  default = true
}

variable "cluster_issuer" {
  default = true
}

variable "external_dns" {
  default = false
}

variable "flux" {
  default = false
}

variable "kanister" {
  default = false
}

variable "rancher_logging" {
  default = false
}

variable "ingress_nginx" {
  default = true
}

variable "olm" {
  default = false
}

variable "rancher_istio" {
  default = false
}

variable "rancher_monitoring" {
  default = false
}

variable "thanos" {
  default = false
}

variable "tempo" {
  default = false
}

variable "longhorn" {
  default = false
}

variable "autoscaler" {
  default = true
}

variable "reloader" {
  default = true
}

variable "argocd" {
  default = false
}

variable "karpenter" {
  default = false
}

variable "kyverno" {
  default = false
}

variable "crossplane" {
  default = false
}

variable "integration_operator" {
  default = false
}

variable "retention_hours" {
  default = 168
}

variable "ingress_ports" {
  default = "80,443"
}

variable "gitlab_username" {
  type = string
}

variable "gitlab_token" {
  type = string
}

variable "gitlab_project_id" {
  type = string
}

variable "email" {
  type = string
}
