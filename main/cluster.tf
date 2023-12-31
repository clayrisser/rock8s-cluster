/**
 * File: /cluster.tf
 * Project: main
 * File Created: 27-09-2023 05:26:35
 * Author: Clay Risser
 * -----
 * BitSpur (c) Copyright 2021 - 2023
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  node_additional_user_data = [
    {
      name    = "user_data.sh"
      type    = "text/x-shellscript"
      content = <<EOF
#!/bin/sh
sudo apt-get update
sudo apt-get install -y \
  nfs-common
EOF
    }
  ]
}

resource "aws_iam_role" "admin" {
  name = local.cluster_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:user/${local.user_name}"
        },
        Condition = {}
      },
    ]
  })
  tags = local.tags
}

resource "aws_key_pair" "node" {
  key_name   = "nodes.${local.cluster_name}"
  public_key = tls_private_key.node.public_key_openssh
}

resource "kops_cluster" "this" {
  name               = local.cluster_name
  admin_ssh_key      = tls_private_key.admin.public_key_openssh
  ssh_key_name       = aws_key_pair.node.key_name
  kubernetes_version = "v1.26.11"
  dns_zone           = var.dns_zone
  cloud_provider {
    aws {
      load_balancer_controller {
        enabled = true
      }
      ebs_csi_driver {
        enabled = true
      }
      pod_identity_webhook {
        enabled = true
      }
      node_termination_handler {
        enabled                           = true
        enable_spot_interruption_draining = true
        enable_sqs_termination_draining   = true
        managed_asg_tag                   = "aws-node-termination-handler/managed"
      }
    }
  }
  authentication {
    aws {
      backend_mode = "CRD"
      cluster_id   = local.cluster_name
      identity_mappings {
        arn      = aws_iam_role.admin.arn
        username = split("/", data.aws_caller_identity.this.arn)[1]
        groups   = ["system:masters"]
      }
    }
  }
  authorization {
    rbac {}
  }
  iam {
    legacy                                   = false
    allow_container_registry                 = true
    use_service_account_external_permissions = true
  }
  external_policies {
    key = "control-plane"
    value = [
      "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess",
      "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
      "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
    ]
  }
  external_policies {
    key = "node"
    value = [
      "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess",
      "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
    ]
  }
  config_store {
    base = "s3://${aws_s3_bucket.main.bucket}/kops/${local.cluster_name}"
  }
  service_account_issuer_discovery {
    enable_aws_oidc_provider = true
    discovery_store          = "s3://${aws_s3_bucket.oidc.bucket}"
  }
  networking {
    network_id = module.vpc.vpc_id
    calico {}
    topology {
      # control_plane = "public"
      # nodes = "public"
      dns = "Public"
    }
    dynamic "subnet" {
      for_each = data.aws_subnet.private
      content {
        type = "Private"
        id   = subnet.value.id
        name = subnet.value.id
        zone = subnet.value.availability_zone
      }
    }
    dynamic "subnet" {
      for_each = data.aws_subnet.utility
      content {
        type = "Utility"
        id   = subnet.value.id
        name = subnet.value.id
        zone = subnet.value.availability_zone
      }
    }
    dynamic "subnet" {
      for_each = data.aws_subnet.public
      content {
        type = "Public"
        id   = subnet.value.id
        name = subnet.value.id
        zone = subnet.value.availability_zone
      }
    }
  }
  api {
    public_name = "api.${local.cluster_name}"
    dynamic "dns" {
      for_each = contains(["DNS"], var.api_strategy) ? [1] : []
      content {}
    }
    dynamic "load_balancer" {
      for_each = contains(["DNS"], var.api_strategy) ? [] : [1]
      content {
        additional_security_groups = [aws_security_group.api.id]
        class                      = "Classic"
        type                       = "Public"
      }
    }
  }
  etcd_cluster {
    name = "main"
    manager {
      backup_retention_days = 90
      listen_metrics_ur_ls  = []
      log_level             = 0
    }
    member {
      name           = "control-plane-0"
      instance_group = "control-plane-0"
    }
  }
  etcd_cluster {
    name = "events"
    manager {
      backup_retention_days = 90
      listen_metrics_ur_ls  = []
      log_level             = 0
    }
    member {
      name           = "control-plane-0"
      instance_group = "control-plane-0"
    }
  }
  cluster_autoscaler {
    enabled                          = var.autoscaler
    aws_use_static_instance_list     = false
    balance_similar_node_groups      = false
    expander                         = "least-waste"
    new_pod_scale_up_delay           = "0s"
    scale_down_delay_after_add       = "10m0s"
    scale_down_utilization_threshold = 0.5
    skip_nodes_with_local_storage    = true
    skip_nodes_with_system_pods      = true
  }
  metrics_server {
    enabled  = true
    insecure = true
  }
  cert_manager {
    enabled = true
    managed = true
  }
  kube_dns {
    provider = "CoreDNS"
    node_local_dns {
      enabled             = true
      forward_to_kube_dns = true
    }
  }
  node_problem_detector {
    enabled = true
  }
  snapshot_controller {
    enabled = true
  }
  karpenter {
    enabled = true
  }
  cloud_config {
    manage_storage_classes {
      value = true
    }
  }
  secrets {
    cluster_ca_cert = tls_self_signed_cert.ca.cert_pem
    cluster_ca_key  = tls_private_key.ca.private_key_pem
  }
  cloud_labels = local.tags
  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      admin_ssh_key,
      secrets,
    ]
  }
}

resource "kops_instance_group" "control-plane-0" {
  cluster_name               = kops_cluster.this.id
  name                       = "control-plane-0"
  role                       = "ControlPlane"
  min_size                   = 1
  max_size                   = 1
  machine_type               = "c5.xlarge"
  subnets                    = [data.aws_subnet.public[0].id]
  additional_security_groups = [aws_security_group.api.id]
  root_volume {
    size = 32
  }
}

resource "kops_instance_group" "karpenter-0" {
  cluster_name       = kops_cluster.this.id
  name               = "karpenter-0"
  manager            = "Karpenter"
  role               = "Node"
  min_size           = 1
  max_size           = 6
  machine_type       = "t3.medium"
  capacity_rebalance = true
  mixed_instances_policy {
    # instances                     = ["t3.medium"]
    on_demand_allocation_strategy = "lowest-price"             # lowest-price prioritized
    spot_allocation_strategy      = "price-capacity-optimized" # price-capacity-optimized lowest-price capacity-optimized diversified
    spot_instance_pools           = 2
    on_demand_above_base { value = 0 }
    on_demand_base { value = 6 }
    instance_requirements {
      cpu {
        min = "4"
        # max = "16"
      }
      memory {
        min = "4G"
        # max = "16G"
      }
    }
  }
  subnets                    = [data.aws_subnet.public[0].id]
  additional_security_groups = [aws_security_group.nodes.id]
  root_volume {
    size = 32
  }
  dynamic "additional_user_data" {
    for_each = local.node_additional_user_data
    content {
      name    = additional_user_data.value["name"]
      type    = additional_user_data.value["type"]
      content = additional_user_data.value["content"]
    }
  }
}

# resource "kops_instance_group" "karpenter-1" {
#   cluster_name       = kops_cluster.this.id
#   name               = "karpenter-1"
#   manager            = "Karpenter"
#   role               = "Node"
#   min_size           = 1
#   max_size           = 6
#   machine_type       = "t3.medium"
#   capacity_rebalance = true
#   mixed_instances_policy {
#     # instances                     = ["t3.medium"]
#     on_demand_allocation_strategy = "lowest-price" # lowest-price prioritized
#     spot_allocation_strategy      = "lowest-price" # price-capacity-optimized lowest-price capacity-optimized diversified
#     spot_instance_pools           = 2
#     on_demand_above_base { value = 0 }
#     on_demand_base { value = 0 }
#     instance_requirements {
#       cpu {
#         min = "2"
#         # max = "16"
#       }
#       memory {
#         min = "2G"
#         # max = "16G"
#       }
#     }
#   }
#   subnets                    = [data.aws_subnet.public[1].id]
#   additional_security_groups = [aws_security_group.nodes.id]
#   root_volume {
#     size = 32
#   }
#   dynamic "additional_user_data" {
#     for_each = local.node_additional_user_data
#     content {
#       name    = additional_user_data.value["name"]
#       type    = additional_user_data.value["type"]
#       content = additional_user_data.value["content"]
#     }
#   }
#   lifecycle {
#     prevent_destroy = false
#   }
# }

# resource "kops_instance_group" "karpenter-2" {
#   cluster_name       = kops_cluster.this.id
#   name               = "karpenter-2"
#   manager            = "Karpenter"
#   role               = "Node"
#   min_size           = 1
#   max_size           = 6
#   machine_type       = "t3.medium"
#   capacity_rebalance = true
#   mixed_instances_policy {
#     # instances                     = ["t3.medium"]
#     on_demand_allocation_strategy = "lowest-price" # lowest-price prioritized
#     spot_allocation_strategy      = "lowest-price" # price-capacity-optimized lowest-price capacity-optimized diversified
#     spot_instance_pools           = 2
#     on_demand_above_base { value = 0 }
#     on_demand_base { value = 0 }
#     instance_requirements {
#       cpu {
#         min = "2"
#         # max = "16"
#       }
#       memory {
#         min = "2G"
#         # max = "16G"
#       }
#     }
#   }
#   subnets                    = [data.aws_subnet.public[2].id]
#   additional_security_groups = [aws_security_group.nodes.id]
#   root_volume {
#     size = 32
#   }
#   dynamic "additional_user_data" {
#     for_each = local.node_additional_user_data
#     content {
#       name    = additional_user_data.value["name"]
#       type    = additional_user_data.value["type"]
#       content = additional_user_data.value["content"]
#     }
#   }
#   lifecycle {
#     prevent_destroy = false
#   }
# }

resource "kops_cluster_updater" "updater" {
  cluster_name = kops_cluster.this.id
  keepers = {
    cluster         = kops_cluster.this.revision
    control-plane-0 = kops_instance_group.control-plane-0.revision
    karpenter-0     = kops_instance_group.karpenter-0.revision
    # karpenter-1     = kops_instance_group.karpenter-1.revision
    # karpenter-2     = kops_instance_group.karpenter-2.revision
  }
  rolling_update {
    skip                = false
    fail_on_drain_error = true
    fail_on_validate    = true
    validate_count      = 1
  }
  validate {
    skip = false
  }
}

resource "null_resource" "wait-for-cluster" {
  provisioner "local-exec" {
    command     = <<EOF
while [ "$(kubectl --kubeconfig <(echo $KUBECONFIG) get nodes | \
  tail -n +2 | \
  grep -vE '^[^ ]+\s+Ready')" != "" ]; do
    sleep 10
done
EOF
    interpreter = ["bash", "-c"]
    environment = {
      KUBECONFIG = local.kubeconfig
    }
  }
  depends_on = [
    kops_cluster_updater.updater
  ]
}
