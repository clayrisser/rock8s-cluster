/**
 * File: /main/firewall.tf
 * Project: kops
 * File Created: 29-09-2022 09:20:26
 * Author: Clay Risser
 * -----
 * Last Modified: 27-06-2023 15:39:42
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

resource "aws_security_group" "api" {
  name   = "api-additional.${local.cluster_name}"
  vpc_id = module.vpc.vpc_id
  dynamic "ingress" {
    for_each = local.public_api_ports
    content {
      from_port        = element(split("-", ingress.value), 0)
      to_port          = element(split("-", ingress.value), length(split("-", ingress.value)) - 1)
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_security_group" "nodes" {
  name   = "nodes-additional.${local.cluster_name}"
  vpc_id = module.vpc.vpc_id
  dynamic "ingress" {
    for_each = local.public_nodes_ports
    content {
      from_port        = element(split("-", ingress.value), 0)
      to_port          = element(split("-", ingress.value), length(split("-", ingress.value)) - 1)
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
  lifecycle {
    prevent_destroy = false
  }
}
