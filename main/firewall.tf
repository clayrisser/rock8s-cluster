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
  tags = merge(local.tags, {
    Name = "api.${local.cluster_name}"
  })
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
  tags = merge(local.tags, {
    Name                     = "nodes.${local.cluster_name}"
    "karpenter.sh/discovery" = local.cluster_name
  })
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_security_group" "ingress" {
  name   = "ingress.${local.cluster_name}"
  vpc_id = module.vpc.vpc_id
  dynamic "ingress" {
    for_each = local.ingress_ports
    content {
      from_port        = element(split("-", ingress.value), 0)
      to_port          = element(split("-", ingress.value), length(split("-", ingress.value)) - 1)
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
  tags = merge(local.tags, {
    Name = "ingress.${local.cluster_name}"
  })
  lifecycle {
    prevent_destroy = false
  }
}
