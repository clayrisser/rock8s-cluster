/**
 * File: /main.tf
 * Project: route53
 * File Created: 16-04-2022 01:29:34
 * Author: Clay Risser
 * -----
 * Last Modified: 17-04-2022 03:39:28
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

terraform {
  required_version = ">= 0.12.26"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

locals {
  zone_name = var.record_type == "PTR" ? format(
    "%s.%s.%s.in-addr.arpa.",
    element(split(".", var.record), 2),
    element(split(".", var.record), 1),
    element(split(".", var.record), 0),
  ) : "${var.domain}."
}

resource "aws_route53_zone" "this" {
  count = var.create_zone ? 1 : 0
  name  = local.zone_name
  vpc {
    vpc_id = data.aws_vpc.this.id
  }
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "aws_route53_record" "this" {
  count   = (var.record_type == "A" || var.record_type == "CNAME") ? 1 : 0
  zone_id = var.create_zone ? aws_route53_zone.this[0].id : data.aws_route53_zone.this[0].zone_id
  name    = "${var.name}.${local.zone_name}"
  type    = var.record_type
  ttl     = var.ttl != null ? tostring(var.ttl) : "300"
  records = [var.record]
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "aws_route53_record" "ptr" {
  count   = var.record_type == "PTR" ? 1 : 0
  zone_id = var.create_zone ? aws_route53_zone.this[0].id : data.aws_route53_zone.this[0].zone_id
  name    = "${element(split(".", var.record), 3)}.${local.zone_name}"
  type    = "PTR"
  ttl     = var.ttl != null ? tostring(var.ttl) : "600"
  records = ["${var.name}.${var.domain}"]
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

data "aws_vpc" "this" {
  default = var.vpc_id ? false : true
  id      = var.vpc_id
}

data "aws_route53_zone" "this" {
  count = var.create_zone ? 0 : 1
  name  = local.zone_name
}
