/**
 * File: /main/efs.tf
 * Project: kops
 * File Created: 28-10-2022 11:25:10
 * Author: Clay Risser
 * -----
 * Last Modified: 29-10-2022 08:31:03
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "aws_iam_policy" "efs_csi_driver" {
  count  = var.efs_csi ? 1 : 0
  name   = "efs-csi-${local.cluster_name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeAvailabilityZones",
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientRootAccess",
        "elasticfilesystem:ClientWrite",
        "elasticfilesystem:DescribeAccessPoints",
        "elasticfilesystem:DescribeFileSystems",
        "elasticfilesystem:DescribeMountTargets"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:CreateAccessPoint"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "elasticfilesystem:DeleteAccessPoint",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "efs_csi_driver" {
  count              = var.efs_csi ? 1 : 0
  name               = "efs-csi-${local.cluster_name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "efs_csi_driver" {
  count      = var.efs_csi ? 1 : 0
  policy_arn = aws_iam_policy.efs_csi_driver[0].arn
  role       = aws_iam_role.efs_csi_driver[0].name
}

resource "aws_efs_file_system" "this" {
  count = var.efs_csi ? 1 : 0
  tags = {
    Name = local.cluster_name
  }
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_efs_mount_target" "this" {
  count           = var.efs_csi ? length(data.aws_subnet.public) : 0
  file_system_id  = aws_efs_file_system.this[0].id
  subnet_id       = data.aws_subnet.public[count.index].id
  security_groups = [data.aws_security_group.nodes.id]
  lifecycle {
    prevent_destroy = false
  }
}

resource "helm_release" "aws_efs_csi_driver" {
  count            = var.efs_csi ? 1 : 0
  version          = "2.2.9"
  name             = "aws-efs-csi-driver"
  repository       = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart            = "aws-efs-csi-driver"
  namespace        = "kube-system"
  create_namespace = true
  values = [<<EOF
image:
  repository: 602401143452.dkr.ecr.${var.region}.amazonaws.com/eks/aws-efs-csi-driver
controller:
  logLevel: 2
  serviceAccount:
    create: true
    name: efs-csi-controller-sa
    annotations:
      eks.amazonaws.com/role-arn: arn:aws:iam::${data.aws_caller_identity.this.id}:role/efs-csi-${local.cluster_name}
node:
  logLevel: 2
  serviceAccount:
    create: true
    name: efs-csi-node-sa
    annotations:
      eks.amazonaws.com/role-arn: arn:aws:iam::${data.aws_caller_identity.this.id}:role/efs-csi-${local.cluster_name}
storageClasses:
  - name: aws-efs
    mountOptions:
      - tls
    parameters:
      provisioningMode: efs-ap
      fileSystemId: ${aws_efs_file_system.this[0].id}
      basePath: '/'
    reclaimPolicy: Delete
    volumeBindingMode: Immediate
EOF
  ]
  depends_on = [
    null_resource.wait_for_nodes,
    aws_efs_mount_target.this,
    aws_iam_role.efs_csi_driver
  ]
  lifecycle {
    prevent_destroy = false
  }
}
