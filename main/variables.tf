/**
 * File: /main/variables.tf
 * Project: kops
 * File Created: 14-04-2022 08:12:06
 * Author: Clay Risser
 * -----
 * Last Modified: 27-06-2023 15:39:42
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
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

variable "cloudflare_email" {
  type    = string
  default = null
}

variable "cloudflare_api_key" {
  type    = string
  default = null
}

variable "iteration" {
  default = 0
}

variable "gitlab_hostname" {
  default = "gitlab.com"
}

variable "rancher_admin_password" {
  default = "rancherP@ssw0rd"
}

variable "flux_git_repository" {
  default = ""
}

variable "flux_git_branch" {
  default = "main"
}

variable "flux_known_hosts" {
  default = ""
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

variable "gitlab_registry_token" {
  type = string
}

variable "gitlab_registry_username" {
  type = string
}

variable "gitlab_project_id" {
  type = string
}

variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_access_key" {
  type = string
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

variable "goldilocks" {
  type    = bool
  default = true
}

variable "integration_operator" {
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

variable "patch_operator" {
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

variable "s3" {
  type    = bool
  default = true
}

variable "tempo" {
  type    = bool
  default = true
}

variable "velero" {
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
