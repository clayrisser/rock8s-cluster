/**
 * File: /modules/kubectl_apply/variables.tf
 * Project: kubernetes_resources
 * File Created: 14-04-2022 07:57:02
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:08:05
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

variable "resources" {
  type = list(string)
}

variable "kubeconfig" {
  type = string
}
