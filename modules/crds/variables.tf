/**
 * File: /main.tf
 * Project: crds
 * File Created: 14-02-2022 15:23:55
 * Author: Clay Risser
 * -----
 * Last Modified: 14-04-2022 08:20:41
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

variable "crds" {
  type = set(string)
}

variable "sleep" {
  type    = string
  default = "3600"
}
