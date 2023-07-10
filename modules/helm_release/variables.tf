/**
 * File: /modules/helm_release/variables.tf
 * Project: kops
 * File Created: 27-09-2022 10:24:31
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:08:37
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

variable "chart_name" {
  type = string
}

variable "chart_version" {
  type = string
}

variable "repo" {
  type = string
}

variable "name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "values" {
  type    = string
  default = "{}"
}

variable "enabled" {
  type    = bool
  default = true
}

variable "rancher_project_id" {
  type    = string
  default = null
}

variable "rancher_cluster_id" {
  type    = string
  default = ""
}
