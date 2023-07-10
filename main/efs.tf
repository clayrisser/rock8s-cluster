/**
 * File: /main/efs.tf
 * Project: kops
 * File Created: 26-06-2023 07:11:51
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:04:24
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

resource "aws_efs_file_system" "elevated" {
  count = var.efs_csi ? 1 : 0
  tags = {
    Name = "elevated.${local.cluster_name}"
  }
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_efs_mount_target" "elevated" {
  count           = var.efs_csi ? length(data.aws_subnet.public) : 0
  file_system_id  = aws_efs_file_system.elevated[0].id
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
node:
  logLevel: 2
  serviceAccount:
    create: true
    name: efs-csi-node-sa
storageClasses:
  - name: efs-sc
    mountOptions:
      - tls
    parameters:
      basePath: /dynamic_provisioning
      directoryPerms: '700'
      fileSystemId: ${aws_efs_file_system.elevated[0].id}
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
    null_resource.wait-for-nodes,
    aws_efs_mount_target.elevated,
  ]
  lifecycle {
    prevent_destroy = false
  }
}
