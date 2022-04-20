/**
 * File: /variables.tf
 * Project: kubernetes_resources
 * File Created: 14-04-2022 07:57:02
 * Author: Clay Risser
 * -----
 * Last Modified: 20-04-2022 05:27:06
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

variable "name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "resources" {
  type = set(string)
}

variable "sleep" {
  type    = string
  default = "3600"
}
