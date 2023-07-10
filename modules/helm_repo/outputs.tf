/**
 * File: /modules/helm_repo/outputs.tf
 * Project: kops
 * File Created: 27-09-2022 10:24:31
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:08:23
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

output "repo" {
  value = local.is_rancher ? rancher2_catalog_v2.this[0].name : var.url
}

output "url" {
  value = local.is_rancher ? rancher2_catalog_v2.this[0].url : var.url
}
