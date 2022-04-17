/**
 * File: /main.tf
 * Project: cloudflare
 * File Created: 16-04-2022 01:29:34
 * Author: Clay Risser
 * -----
 * Last Modified: 17-04-2022 03:39:06
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
  zone_id = var.create_zone ? cloudflare_zone.this[0].id : lookup(data.cloudflare_zones.this[0].zones[0], "id")
  name    = var.name
  ttl     = var.ttl != null ? var.ttl : 3600
  type    = var.record_type
  value   = var.record
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "cloudflare_zone" "this" {
  count = var.create_zone ? 1 : 0
  zone  = var.domain
}

data "cloudflare_zones" "this" {
  count = var.create_zone ? 0 : 1
  filter {
    name = var.domain
  }
}
