/**
 * File: /data.tf
 * Project: main
 * File Created: 14-04-2022 08:09:15
 * Author: Clay Risser
 * -----
 * Last Modified: 19-04-2022 08:20:58
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "this" {}

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_id
}

data "aws_ami" "eks_default_bottlerocket" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["bottlerocket-aws-k8s-${var.cluster_version}-x86_64-*"]
  }
}
