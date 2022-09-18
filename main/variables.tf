/**
 * File: /main/variables.tf
 * Project: kops
 * File Created: 14-04-2022 08:12:06
 * Author: Clay Risser
 * -----
 * Last Modified: 18-09-2022 10:55:32
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
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

variable "loki_chunks_bucket" {
  default = ""
}

variable "loki_ruler_bucket" {
  default = ""
}

variable "loki_admin_bucket" {
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
