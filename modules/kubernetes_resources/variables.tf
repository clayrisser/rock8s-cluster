/**
 * File: /variables.tf
 * Project: kubernetes_resources
 * File Created: 14-04-2022 07:57:02
 * Author: Clay Risser
 * -----
 * Last Modified: 20-04-2022 13:32:13
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

variable "resources" {
  type = list(string)
}

variable "kubeconfig" {
  type = string
}

variable "sleep" {
  type    = string
  default = "3600"
}
