/**
 * File: /eks.tf
 * Project: main
 * File Created: 14-04-2022 08:13:23
 * Author: Clay Risser
 * -----
 * Last Modified: 20-04-2022 10:55:32
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "aws_kms_key" "eks" {
  description             = "${local.cluster_name} secret encryption key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags = {
    Name = local.cluster_name
  }
}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  cluster_name                    = local.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  create                          = true
  create_iam_role                 = true
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    ingress_cluster_all = {
      description                   = "Cluster to node all ports/protocols"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
  cluster_addons = {
    kube-proxy = {}
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }
  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.public_subnets
  enable_irsa = true
  eks_managed_node_group_defaults = {
    disk_size            = 64
    instance_types       = ["t2.medium"]
    ami_type             = "BOTTLEROCKET_x86_64"
    platform             = "bottlerocket"
    bootstrap_extra_args = <<-EOT
    EOT
  }
  self_managed_node_group_defaults = {
    disk_size            = 64
    instance_type        = "t2.medium"
    ami_id               = data.aws_ami.eks_default_bottlerocket.id
    platform             = "bottlerocket"
    bootstrap_extra_args = <<-EOT
    EOT
  }
  eks_managed_node_groups = {
    dedicated = {
      min_size     = 2
      max_size     = 2
      desired_size = 2
    }
    dedicated2 = {
      min_size     = 2
      max_size     = 2
      desired_size = 2
    }
  }
  self_managed_node_groups = {}
  tags = {
    Name = local.cluster_name
  }
}

resource "null_resource" "wait_for_nodes" {
  provisioner "local-exec" {
    command     = <<EOF
while [ "$(kubectl --kubeconfig <(echo $KUBECONFIG) get nodes | \
  tail -n +2 | \
  grep -vE '^[^ ]+\s+Ready')" != "" ]; do
    sleep 10
done
EOF
    interpreter = ["sh", "-c"]
    environment = {
      KUBECONFIG = local.kubeconfig
    }
  }
  depends_on = [
    module.eks
  ]
}
