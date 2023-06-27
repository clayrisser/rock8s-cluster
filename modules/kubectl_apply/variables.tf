/**
 * File: /modules/kubectl_apply/variables.tf
 * Project: kubernetes_resources
 * File Created: 14-04-2022 07:57:02
 * Author: Clay Risser
 * -----
 * Last Modified: 27-06-2023 15:39:42
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
