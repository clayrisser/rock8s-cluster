/**
 * File: /main/efs.tf
 * Project: kops
 * File Created: 28-10-2022 11:25:10
 * Author: Clay Risser
 * -----
 * Last Modified: 01-11-2022 12:30:21
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

# https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html
# https://medium.com/codex/irsa-implementation-in-kops-managed-kubernetes-cluster-18cef84960b6

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
        "elasticfilesystem:*",
        "ec2:DescribeAvailabilityZones"
      ],
      "Resource": "*"
    }
  ]
}
EOF
  lifecycle {
    prevent_destroy = false
  }
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
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.this.id}:oidc-provider/${aws_s3_bucket.oidc.bucket}.s3.${var.region}.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${aws_s3_bucket.oidc.bucket}.s3.${var.region}.amazonaws.com:sub": "system:serviceaccount:kube-system:efs-csi-controller-sa"
        }
      }
    }
  ]
}
EOF
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_iam_role_policy_attachment" "efs_csi_driver" {
  count      = var.efs_csi ? 1 : 0
  policy_arn = aws_iam_policy.efs_csi_driver[0].arn
  role       = aws_iam_role.efs_csi_driver[0].name
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_iam_role_policy_attachment" "nodes_efs_csi_driver" {
  count      = var.efs_csi ? 1 : 0
  policy_arn = aws_iam_policy.efs_csi_driver[0].arn
  role       = data.aws_iam_role.nodes.name
  lifecycle {
    prevent_destroy = false
  }
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
      # eks.amazonaws.com/role-arn: arn:aws:iam::${data.aws_caller_identity.this.id}:role/efs-csi-${local.cluster_name}
node:
  logLevel: 2
  serviceAccount:
    create: true
    name: efs-csi-node-sa
    annotations:
      # eks.amazonaws.com/role-arn: arn:aws:iam::${data.aws_caller_identity.this.id}:role/efs-csi-${local.cluster_name}
storageClasses:
  - name: efs-sc
    mountOptions:
      - tls
    parameters:
      basePath: /dynamic_provisioning
      directoryPerms: '700'
      fileSystemId: ${aws_efs_file_system.this[0].id}
      gid: '1000'
      gidRangeEnd: '2000'
      gidRangeStart: '1000'
      provisioningMode: efs-ap
      uid: '1000'
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
