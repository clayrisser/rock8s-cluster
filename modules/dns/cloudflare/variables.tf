/**
 * File: /variables.tf
 * Project: cloudflare
 * File Created: 16-04-2022 01:29:34
 * Author: Clay Risser
 * -----
 * Last Modified: 16-04-2022 01:32:37
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

variable "ip" {
  type = string
}

variable "zone_id" {
  type = string
}

variable "cname" {
  type    = string
  default = "kube"
}

variable "record_type" {
  type    = string
  default = "A"
}
