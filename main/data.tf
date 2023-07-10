/**
 * File: /main/data.tf
 * Project: kops
 * File Created: 14-04-2022 08:09:15
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:05:13
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

data "aws_iam_role" "nodes" {
  name = "nodes.${local.cluster_name}"
  depends_on = [
    kops_cluster_updater.updater
  ]
}

data "aws_iam_role" "masters" {
  name = "masters.${local.cluster_name}"
  depends_on = [
    kops_cluster_updater.updater
  ]
}

data "aws_caller_identity" "this" {}

data "aws_subnet" "public" {
  count  = length(module.vpc.public_subnets)
  id     = module.vpc.public_subnets[count.index]
  vpc_id = module.vpc.vpc_id
}

data "aws_subnet" "private" {
  count  = length(module.vpc.private_subnets)
  id     = module.vpc.private_subnets[count.index]
  vpc_id = module.vpc.vpc_id
}

data "kubernetes_service" "ingress-nginx-controller" {
  count = var.ingress_nginx ? 1 : 0
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  depends_on = [
    helm_release.ingress-nginx,
  ]
}

data "aws_route53_zone" "this" {
  name = var.dns_zone
}

data "aws_security_group" "nodes" {
  tags = {
    Name = "nodes.${local.cluster_name}"
  }
  depends_on = [
    kops_cluster_updater.updater
  ]
}
