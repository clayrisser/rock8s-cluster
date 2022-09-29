/**
 * File: /main/firewall.tf
 * Project: kops
 * File Created: 29-09-2022 09:20:26
 * Author: Clay Risser
 * -----
 * Last Modified: 29-09-2022 09:20:40
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "aws_security_group" "api" {
  name   = "api-additional.${local.cluster_name}"
  vpc_id = module.vpc.vpc_id
  dynamic "ingress" {
    for_each = local.public_api_ports
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "aws_security_group" "nodes" {
  name   = "nodes-additional.${local.cluster_name}"
  vpc_id = module.vpc.vpc_id
  dynamic "ingress" {
    for_each = local.public_nodes_ports
    content {
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
  ingress {
    from_port        = "30000"
    to_port          = "32768"
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
