/**
 * File: /eks.tf
 * Project: main
 * File Created: 14-04-2022 08:13:23
 * Author: Clay Risser
 * -----
 * Last Modified: 23-04-2022 09:01:12
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

locals {
  tags = {
    Name = local.cluster_name
  }
}

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
  enable_irsa                     = true
  subnet_ids                      = module.vpc.public_subnets
  vpc_id                          = module.vpc.vpc_id
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
  }
  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]
  eks_managed_node_group_defaults = {
    disk_size            = 64
    instance_types       = ["t2.medium"]
    ami_type             = "BOTTLEROCKET_x86_64"
    platform             = "bottlerocket"
    create_iam_role      = true
    bootstrap_extra_args = <<-EOT
    [settings.kubernetes]
    max-pods = 110
    EOT
  }
  self_managed_node_group_defaults = {
    disk_size            = 64
    instance_type        = "t2.medium"
    ami_id               = data.aws_ami.eks_default_bottlerocket.id
    platform             = "bottlerocket"
    create_iam_role      = true
    bootstrap_extra_args = <<-EOT
    [settings.kubernetes]
    max-pods = 110
    EOT
  }
  # eks_managed_node_groups  = var.cni == "calico" ? {} : var.eks_managed_node_groups
  # self_managed_node_groups = var.cni == "calico" ? {} : var.self_managed_node_groups
  eks_managed_node_groups  = var.eks_managed_node_groups
  self_managed_node_groups = var.self_managed_node_groups
  tags                     = local.tags
}

# resource "aws_eks_addon" "corends" {
#   cluster_name      = local.cluster_name
#   addon_name        = "coredns"
#   resolve_conflicts = "OVERWRITE"
#   tags              = local.tags
#   lifecycle {
#     ignore_changes = [
#       modified_at
#     ]
#   }
#   depends_on = [
#     module.eks
#   ]
# }

# resource "aws_eks_addon" "kube_proxy" {
#   cluster_name = local.cluster_name
#   addon_name   = "kube-proxy"
#   tags         = local.tags
#   lifecycle {
#     ignore_changes = [
#       modified_at
#     ]
#   }
#   depends_on = [
#     module.eks
#   ]
# }

# module "node_groups" {
#   count                              = var.cni == "calico" ? 1 : 0
#   source                             = "../modules/eks_node_groups"
#   cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
#   cluster_endpoint                   = module.eks.cluster_endpoint
#   cluster_name                       = local.cluster_name
#   cluster_primary_security_group_id  = module.eks.cluster_primary_security_group_id
#   cluster_security_group_id          = module.eks.cluster_security_group_id
#   node_security_group_id             = module.eks.node_security_group_id
#   cluster_version                    = module.eks.cluster_version
#   create                             = true
#   subnet_ids                         = module.vpc.public_subnets
#   vpc_id                             = module.vpc.vpc_id
#   eks_managed_node_group_defaults = {
#     disk_size            = 64
#     instance_types       = ["t2.medium"]
#     ami_type             = "BOTTLEROCKET_x86_64"
#     platform             = "bottlerocket"
#     create_iam_role      = true
#     bootstrap_extra_args = <<-EOT
#     [settings.kubernetes]
#     max-pods = 110
#     EOT
#   }
#   self_managed_node_group_defaults = {
#     disk_size            = 64
#     instance_type        = "t2.medium"
#     ami_id               = data.aws_ami.eks_default_bottlerocket.id
#     platform             = "bottlerocket"
#     create_iam_role      = true
#     bootstrap_extra_args = <<-EOT
#     [settings.kubernetes]
#     max-pods = 110
#     EOT
#   }
#   eks_managed_node_groups  = var.eks_managed_node_groups
#   self_managed_node_groups = var.self_managed_node_groups
# }

resource "null_resource" "wait_for_vpc_cni" {
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
    module.eks,
  ]
}

resource "null_resource" "remove_vpc_cni" {
  count = var.cni == "calico" ? 1 : 0
  provisioner "local-exec" {
    command     = <<-EOT
      aws eks delete-addon --cluster-name $CLUSTER_NAME \
        --addon-name vpc-cni \
        --no-preserve || true
      sleep 60
      curl https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/release-1.7/config/v1.7/aws-k8s-cni.yaml | \
        sed 's|apiextensions.k8s.io/v1beta1|apiextensions.k8s.io/v1|g' | \
        kubectl --kubeconfig <(echo $KUBECONFIG) delete -f - || true
      kubectl delete daemonset aws-node -n kube-system || true
    EOT
    interpreter = ["sh", "-c"]
    environment = {
      CLUSTER_NAME = local.cluster_name
    }
  }
  depends_on = [
    null_resource.wait_for_vpc_cni
  ]
}

resource "helm_release" "calico" {
  version    = "v3.21.4"
  name       = "calico"
  repository = "https://docs.projectcalico.org/charts"
  chart      = "tigera-operator"
  values = [<<EOF
{}
EOF
  ]
  depends_on = [
    null_resource.wait_for_vpc_cni
  ]
}

resource "null_resource" "rotate_nodes" {
  provisioner "local-exec" {
    command     = <<EOF
aws ec2 terminate-instances --instance-ids $( \
    echo $(
        aws ec2 describe-instances \
            --filter Name=tag:eks:nodegroup-name,Values=$( \
                echo $(aws eks list-nodegroups --cluster-name $CLUSTER_NAME | jq -r '.nodegroups[]') | sed 's| |,|g' \
            ) | \
            jq -r '.Reservations[].Instances[].InstanceId'
    )
)
EOF
    interpreter = ["sh", "-c"]
    environment = {
      KUBECONFIG = local.kubeconfig
    }
  }
  depends_on = [
    helm_release.calico,
    null_resource.remove_vpc_cni
  ]
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
    null_resource.rotate_nodes
  ]
}
