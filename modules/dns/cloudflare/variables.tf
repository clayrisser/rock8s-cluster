/**
 * File: /variables.tf
 * Project: cloudflare
 * File Created: 16-04-2022 01:29:34
 * Author: Clay Risser
 * -----
 * Last Modified: 16-04-2022 03:30:22
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

variable "name" {
  type = string
}

variable "domain" {
  type = string
}

variable "record" {
  type = string
}

variable "record_type" {
  default = "A"
}

variable "create_zone" {
  default = false
}

variable "ttl" {
  type    = number
  default = null
}
