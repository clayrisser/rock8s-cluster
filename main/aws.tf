/**
 * File: /main/aws.tf
 * Project: kops
 * File Created: 29-04-2022 14:41:49
 * Author: Clay Risser
 * -----
 * Last Modified: 28-10-2022 11:22:50
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "aws_iam_role" "admin" {
  name = local.cluster_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"
        },
        Condition = {}
      },
    ]
  })
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_key_pair" "node" {
  key_name   = "nodes.${local.cluster_name}"
  public_key = tls_private_key.node.public_key_openssh
  lifecycle {
    prevent_destroy = false
  }
}

resource "helm_release" "aws_efs_csi_driver" {
  version          = "2.2.9"
  count            = var.aws_efs_csi_driver ? 1 : 0
  name             = "aws-efs-csi-driver"
  repository       = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart            = "aws-efs-csi-driver"
  namespace        = "kube-system"
  create_namespace = true
  values = [<<EOF
image:
  repository: 602401143452.dkr.ecr.${var.region}.amazonaws.com/eks/aws-efs-csi-driver
controller:
  serviceAccount:
    name: efs-csi-controller-sa
    create: false
EOF
  ]
  depends_on = [
    null_resource.wait_for_nodes
  ]
  lifecycle {
    prevent_destroy = false
  }
}
