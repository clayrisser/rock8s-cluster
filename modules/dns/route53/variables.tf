/**
 * File: /variables.tf
 * Project: route53
 * File Created: 16-04-2022 01:29:34
 * Author: Clay Risser
 * -----
 * Last Modified: 16-04-2022 01:42:16
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

variable "record" {
  type    = string
  default = ""
}

variable "name" {
  type = string
}

variable "domain" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-2"
}

variable "create_zone" {
  type    = bool
  default = false
}

variable "record_type" {
  type    = string
  default = "A"
}

variable "ttl" {
  type    = string
  default = null
}
