/**
 * File: /main/efs.tf
 * Project: kops
 * File Created: 28-10-2022 11:25:10
 * Author: Clay Risser
 * -----
 * Last Modified: 28-10-2022 12:17:18
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

data "aws_subnet_ids" "kops" {
  vpc_id = module.vpc.vpc_id
  depends_on = [
    null_resource.wait_for_nodes
  ]
}

data "aws_security_group" "kops_nodes" {
  tags = {
    Name = "nodes.${local.cluster_name}"
  }
  depends_on = [
    null_resource.wait_for_nodes
  ]
}

resource "aws_efs_file_system" "efs" {
  tags = {
    Name = local.cluster_name
  }
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_efs_mount_target" "efs" {
  count           = var.efs_csi ? length(data.aws_subnet_ids.kops.ids) : 0
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = data.aws_subnet_ids.kops.ids[count.index]
  security_groups = [data.aws_security_group.kops_nodes.id]
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
  serviceAccount:
    name: efs-csi-controller-sa
    create: true
storageClasses:
  - name: efs
    mountOptions:
      - tls
    parameters:
      provisioningMode: efs-ap
      fileSystemId: ${aws_efs_file_system.efs.id}
      basePath: '/'
    reclaimPolicy: Delete
    volumeBindingMode: Immediate
EOF
  ]
  depends_on = [
    null_resource.wait_for_nodes,
    aws_efs_mount_target.efs
  ]
  lifecycle {
    prevent_destroy = false
  }
}
