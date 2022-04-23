/**
 * File: /variables.tf
 * Project: main
 * File Created: 14-04-2022 08:12:06
 * Author: Clay Risser
 * -----
 * Last Modified: 23-04-2022 08:51:57
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */


variable "eks_managed_node_groups" {
  default = {
    dedicated1 = {
      min_size     = 3
      max_size     = 3
      desired_size = 3
    }
  }
}

variable "self_managed_node_groups" {
  default = {}
}

variable "region" {
  default = "us-east-2"
}

variable "cluster_name" {
  default = "eks-main"
}

variable "cluster_version" {
  default = "1.22"
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

variable "bucket" {
  default = ""
}

variable "domain" {
  type = string
}

variable "gitlab_registry_token" {
  type = string
}

variable "gitlab_registry_username" {
  type = string
}

variable "gitlab_token" {
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

variable "cni" {
  default = "calico"
}
