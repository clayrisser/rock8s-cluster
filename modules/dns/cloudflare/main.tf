/**
 * File: /main.tf
 * Project: cloudflare
 * File Created: 16-04-2022 01:29:34
 * Author: Clay Risser
 * -----
 * Last Modified: 16-04-2022 01:32:28
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

terraform {
  required_version = ">= 0.12.26"
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

resource "cloudflare_record" "rancher" {
  zone_id = var.zone_id
  name    = var.name
  ttl     = 3600
  type    = var.record_type
  value   = var.ip
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
