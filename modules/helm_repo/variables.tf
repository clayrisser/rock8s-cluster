/**
 * File: /modules/helm_repo/variables.tf
 * Project: kops
 * File Created: 27-09-2022 10:24:31
 * Author: Clay Risser
 * -----
 * Last Modified: 27-06-2023 15:39:42
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

variable "name" {
  type = string
}

variable "url" {
  type = string
}

variable "rancher_cluster_id" {
  type    = string
  default = ""
}
