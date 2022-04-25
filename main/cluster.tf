/**
 * File: /cluster.tf
 * Project: main
 * File Created: 14-04-2022 08:13:23
 * Author: Clay Risser
 * -----
 * Last Modified: 25-04-2022 16:53:31
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem
  subject {
    common_name  = "Example CA"
    organization = "Example, Ltd"
    country      = "GB"
  }
  validity_period_hours = 43800
  is_ca_certificate     = true
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

resource "tls_private_key" "cluster" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "kops_cluster" "this" {
  name           = local.cluster_name
  admin_ssh_key  = tls_private_key.cluster.public_key_openssh
  cloud_provider = "aws"
  # kubernetes_version = var.cluster_version
  dns_zone   = var.dns_zone
  network_id = module.vpc.vpc_id
  iam {
    allow_container_registry                 = true
    use_service_account_external_permissions = false
  }
  networking {
    calico {}
  }
  topology {
    masters = "public"
    nodes   = "public"
    dns {
      type = "Public"
    }
  }
  api {
    dns {}
  }
  etcd_cluster {
    name = "main"
    member {
      name           = "master-0"
      instance_group = "master-0"
    }
    member {
      name           = "master-1"
      instance_group = "master-1"
    }
    member {
      name           = "master-2"
      instance_group = "master-2"
    }
  }
  etcd_cluster {
    name = "events"
    member {
      name           = "master-0"
      instance_group = "master-0"
    }
    member {
      name           = "master-1"
      instance_group = "master-1"
    }
    member {
      name           = "master-2"
      instance_group = "master-2"
    }
  }
  dynamic "subnet" {
    for_each = data.aws_subnet.private
    content {
      type        = "Private"
      name        = subnet.value.id
      cidr        = subnet.value.cidr_block
      provider_id = subnet.value.id
      zone        = subnet.value.availability_zone
    }
  }
  dynamic "subnet" {
    for_each = data.aws_subnet.public
    content {
      type        = "Public"
      name        = subnet.value.id
      cidr        = subnet.value.cidr_block
      provider_id = subnet.value.id
      zone        = subnet.value.availability_zone
    }
  }
  provisioner "local-exec" {
    command     = <<EOF
echo '${tls_private_key.cluster.public_key_openssh}' > ../cluster_ecdsa.pub
EOF
    interpreter = ["sh", "-c"]
    environment = {}
  }
}

resource "kops_instance_group" "master-0" {
  cluster_name = kops_cluster.this.id
  name         = "master-0"
  role         = "Master"
  min_size     = 1
  max_size     = 1
  machine_type = "t3.medium"
  subnets      = [data.aws_subnet.public[0].id]
}

resource "kops_instance_group" "master-1" {
  cluster_name = kops_cluster.this.id
  name         = "master-1"
  role         = "Master"
  min_size     = 1
  max_size     = 1
  machine_type = "t3.medium"
  subnets      = [data.aws_subnet.public[1].id]
}

resource "kops_instance_group" "master-2" {
  cluster_name = kops_cluster.this.id
  name         = "master-2"
  role         = "Master"
  min_size     = 1
  max_size     = 1
  machine_type = "t3.medium"
  subnets      = [data.aws_subnet.public[2].id]
}

resource "kops_instance_group" "node-0" {
  cluster_name = kops_cluster.this.id
  name         = "node-0"
  role         = "Node"
  min_size     = 1
  max_size     = 2
  machine_type = "t3.medium"
  subnets      = [data.aws_subnet.public[0].id]
}

resource "kops_instance_group" "node-1" {
  cluster_name = kops_cluster.this.id
  name         = "node-1"
  role         = "Node"
  min_size     = 1
  max_size     = 2
  machine_type = "t3.medium"
  subnets      = [data.aws_subnet.public[1].id]
}

resource "kops_instance_group" "node-2" {
  cluster_name = kops_cluster.this.id
  name         = "node-2"
  role         = "Node"
  min_size     = 1
  max_size     = 2
  machine_type = "t3.medium"
  subnets      = [data.aws_subnet.public[2].id]
}

# resource "null_resource" "ca" {
#   provisioner "local-exec" {
#     command     = <<EOF
# echo "${tls_self_signed_cert.ca.cert_pem}" > ../ca.crt
# echo "${tls_private_key.ca.private_key_pem}" > ../ca.key
# kops create keypair kubernetes-ca \
#   --primary \
#   --cert ../ca.crt \
#   --key ../ca.key \
#   --state '${local.kops_state_store}' \
#   --name '${local.cluster_name}'
# EOF
#     interpreter = ["sh", "-c"]
#     environment = {}
#   }
#   depends_on = [
#     kops_cluster.this,
#   ]
# }

# resource "null_resource" "admin_password" {
#   provisioner "local-exec" {
#     command     = <<EOF
# alias b64="$(openssl version >/dev/null 2>/dev/null && echo openssl base64 || echo base64)"
# echo "{\"Data\":\"$(echo $PASSWORD | b64)\"}" | \
#  aws s3 cp - '${local.kops_state_store}/${local.cluster_name}/secrets/admin'
# EOF
#     interpreter = ["sh", "-c"]
#     environment = {
#       PASSWORD = "P@ssw0rd"
#     }
#   }
#   depends_on = [
#     kops_cluster.this,
#   ]
# }

resource "kops_cluster_updater" "updater" {
  cluster_name = kops_cluster.this.id

  keepers = {
    cluster  = kops_cluster.this.revision
    master-0 = kops_instance_group.master-0.revision
    master-1 = kops_instance_group.master-1.revision
    master-2 = kops_instance_group.master-2.revision
    node-0   = kops_instance_group.node-0.revision
    node-1   = kops_instance_group.node-1.revision
    node-2   = kops_instance_group.node-2.revision
  }

  rolling_update {
    skip                = false
    fail_on_drain_error = true
    fail_on_validate    = false
    validate_count      = 1
  }

  validate {
    skip = false
  }
  # depends_on = [
  #   null_resource.ca,
  #   null_resource.admin_password
  # ]
}

resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command     = <<EOF
kops export kubeconfig '${local.cluster_name}' \
  --state '${local.kops_state_store}' \
  --admin \
  --kubeconfig ${local.kops_kubeconfig_file}
EOF
    interpreter = ["sh", "-c"]
    environment = {}
  }
  depends_on = [
    kops_cluster.this,
    kops_cluster_updater.updater
  ]
}

# module "eks" {
#   source                          = "terraform-aws-modules/eks/aws"
#   cluster_name                    = local.cluster_name
#   cluster_version                 = var.cluster_version
#   cluster_endpoint_private_access = true
#   cluster_endpoint_public_access  = true
#   create                          = true
#   create_iam_role                 = true
#   enable_irsa                     = true
#   subnet_ids                      = module.vpc.public_subnets
#   vpc_id                          = module.vpc.vpc_id
#   cluster_security_group_additional_rules = {
#     egress_nodes_ephemeral_ports_tcp = {
#       description                = "To node 1025-65535"
#       protocol                   = "tcp"
#       from_port                  = 1025
#       to_port                    = 65535
#       type                       = "egress"
#       source_node_security_group = true
#     }
#   }
#   node_security_group_additional_rules = {
#     ingress_self_all = {
#       description = "Node to node all ports/protocols"
#       protocol    = "-1"
#       from_port   = 0
#       to_port     = 0
#       type        = "ingress"
#       self        = true
#     }
#     ingress_cluster_all = {
#       description                   = "Cluster to node all ports/protocols"
#       protocol                      = "-1"
#       from_port                     = 0
#       to_port                       = 0
#       type                          = "ingress"
#       source_cluster_security_group = true
#     }
#     egress_all = {
#       description      = "Node all egress"
#       protocol         = "-1"
#       from_port        = 0
#       to_port          = 0
#       type             = "egress"
#       cidr_blocks      = ["0.0.0.0/0"]
#       ipv6_cidr_blocks = ["::/0"]
#     }
#   }
#   cluster_encryption_config = [{
#     provider_key_arn = aws_kms_key.eks.arn
#     resources        = ["secrets"]
#   }]
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
#     instance_type        = "t2.large"
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
#   tags                     = local.tags
# }

# resource "null_resource" "wait_for_nodes" {
#   provisioner "local-exec" {
#     command     = <<EOF
# while [ "$(kubectl --kubeconfig <(echo $KUBECONFIG) get nodes | \
#   tail -n +2 | \
#   grep -vE '^[^ ]+\s+Ready')" != "" ]; do
#     sleep 10
# done
# EOF
#     interpreter = ["sh", "-c"]
#     environment = {
#       KUBECONFIG = local.kubeconfig
#     }
#   }
#   depends_on = [
#     kops_cluster.this
#   ]
# }
