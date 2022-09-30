/**
 * File: /main/cluster.tf
 * Project: kops
 * File Created: 14-04-2022 08:13:23
 * Author: Clay Risser
 * -----
 * Last Modified: 30-09-2022 08:46:17
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "local_file" "iam_kubeconfig" {
  content  = yamlencode(local.kubeconfig)
  filename = "${path.module}/../artifacts/iam_kubeconfig"
}

resource "kops_cluster" "this" {
  name               = local.cluster_name
  admin_ssh_key      = tls_private_key.admin.public_key_openssh
  ssh_key_name       = aws_key_pair.node.key_name
  kubernetes_version = "v1.21.12"
  dns_zone           = var.dns_zone
  network_id         = module.vpc.vpc_id
  cloud_provider {
    aws {}
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
    always_allow {}
  }
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
    member {
      name           = "master-0"
      instance_group = "master-0"
    }
    # member {
    #   name           = "master-1"
    #   instance_group = "master-1"
    # }
    # member {
    #   name           = "master-2"
    #   instance_group = "master-2"
    # }
  }
  etcd_cluster {
    name = "events"
    member {
      name           = "master-0"
      instance_group = "master-0"
    }
    # member {
    #   name           = "master-1"
    #   instance_group = "master-1"
    # }
    # member {
    #   name           = "master-2"
    #   instance_group = "master-2"
    # }
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
  aws_load_balancer_controller {
    enabled = true
  }
  cluster_autoscaler {
    aws_use_static_instance_list     = false
    balance_similar_node_groups      = false
    enabled                          = var.autoscaler
    expander                         = "least-waste"
    new_pod_scale_up_delay           = "0s"
    scale_down_delay_after_add       = "10m0s"
    scale_down_utilization_threshold = 0.5
    skip_nodes_with_local_storage    = true
    skip_nodes_with_system_pods      = true
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
  node_termination_handler {
    enabled                           = true
    enable_spot_interruption_draining = true
    enable_sqs_termination_draining   = true
    managed_asg_tag                   = "aws-node-termination-handler/managed"
  }
  node_problem_detector {
    enabled = true
  }
  pod_identity_webhook {
    enabled = true
  }
  snapshot_controller {
    enabled = true
  }
  cloud_config {
    manage_storage_classes = true
    aws_ebs_csi_driver {
      enabled = true
    }
  }
  secrets {
    cluster_ca_cert = tls_self_signed_cert.ca.cert_pem
    cluster_ca_key  = tls_private_key.ca.private_key_pem
  }
  depends_on = [
    local_file.admin_rsa,
    local_file.admin_rsa_pub,
    local_file.iam_kubeconfig,
    local_file.node_rsa,
    local_file.node_rsa_pub,
  ]
  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      secrets,
    ]
  }
}

resource "kops_instance_group" "master-0" {
  cluster_name               = kops_cluster.this.id
  name                       = "master-0"
  role                       = "Master"
  min_size                   = 1
  max_size                   = 1
  machine_type               = "t3.xlarge"
  subnets                    = [data.aws_subnet.public[0].id]
  additional_security_groups = [aws_security_group.api.id]
  additional_user_data = [
    {
      name    = "assign-eip.sh"
      type    = "text/x-shellscript"
      content = <<EOF
#!/bin/bash
export EIPPOOL=${var.cluster_prefix}.${var.dns_zone}
set -o nounset
set -o errexit
apk -q --no-cache add curl
ASSOCIATED_INSTANCES=$(aws ec2 describe-addresses --filters="Name=tag:Name,Values=$EIPPOOL" | jq -r '.Addresses[] | "\(.InstanceId)"')
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
while ! [[ $ASSOCIATED_INSTANCES =~ (^|[[:space:]])"$INSTANCE_ID"($|[[:space:]]) ]]; do
  ALLOCATION_ID=$(aws ec2 describe-addresses --filters="Name=tag:Name,Values=$EIPPOOL" | jq -r '.Addresses[] | "\(.InstanceId) \(.AllocationId)"' | grep null | awk '{print $2}' | xargs shuf -n1 -e)
  if [ ! -z $ALLOCATION_ID ]; then
    aws ec2 associate-address --instance-id $INSTANCE_ID --allocation-id $ALLOCATION_ID --allow-reassociation
    ASSOCIATED_INSTANCES=$(aws ec2 describe-addresses --filters="Name=tag:Name,Values=$EIPPOOL" | jq -r '.Addresses[] | "\(.InstanceId)"')
  else
    sleep 60
  fi
done
EOF
    }
  ]
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

# resource "kops_instance_group" "master-1" {
#   cluster_name               = kops_cluster.this.id
#   name                       = "master-1"
#   role                       = "Master"
#   min_size                   = 1
#   max_size                   = 1
#   machine_type               = "t3.medium"
#   subnets                    = [data.aws_subnet.public[1].id]
#   additional_security_groups = [aws_security_group.api.id]
#   lifecycle {
#     prevent_destroy = false
#     ignore_changes  = []
#   }
# }

# resource "kops_instance_group" "master-2" {
#   cluster_name               = kops_cluster.this.id
#   name                       = "master-2"
#   role                       = "Master"
#   min_size                   = 1
#   max_size                   = 1
#   machine_type               = "t3.medium"
#   subnets                    = [data.aws_subnet.public[2].id]
#   additional_security_groups = [aws_security_group.api.id]
#   lifecycle {
#     prevent_destroy = false
#     ignore_changes  = []
#   }
# }

resource "kops_instance_group" "t3-medium-a" {
  cluster_name               = kops_cluster.this.id
  name                       = "t3-medium-a"
  autoscale                  = true
  role                       = "Node"
  min_size                   = 2
  max_size                   = 3
  machine_type               = "t3.medium"
  subnets                    = [data.aws_subnet.public[0].id]
  additional_security_groups = [aws_security_group.nodes.id]
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "kops_instance_group" "t3-medium-b" {
  cluster_name               = kops_cluster.this.id
  name                       = "t3-medium-b"
  autoscale                  = true
  role                       = "Node"
  min_size                   = 1
  max_size                   = 3
  machine_type               = "t3.medium"
  subnets                    = [data.aws_subnet.public[1].id]
  additional_security_groups = [aws_security_group.nodes.id]
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "kops_instance_group" "t3-medium-c" {
  cluster_name               = kops_cluster.this.id
  name                       = "t3-medium-c"
  autoscale                  = true
  role                       = "Node"
  min_size                   = 1
  max_size                   = 3
  machine_type               = "t3.medium"
  subnets                    = [data.aws_subnet.public[2].id]
  additional_security_groups = [aws_security_group.nodes.id]
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "kops_cluster_updater" "updater" {
  cluster_name = kops_cluster.this.id
  keepers = {
    cluster  = kops_cluster.this.revision
    master-0 = kops_instance_group.master-0.revision
    # master-1 = kops_instance_group.master-1.revision
    # master-2 = kops_instance_group.master-2.revision
    t3-medium-a = kops_instance_group.t3-medium-a.revision
    t3-medium-b = kops_instance_group.t3-medium-b.revision
    t3-medium-c = kops_instance_group.t3-medium-c.revision
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
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command     = <<EOF
mkdir -p ../artifacts
kops export kubeconfig '${local.cluster_name}' \
  --state '${local.kops_state_store}' \
  --admin \
  --kubeconfig ../artifacts/kubeconfig
EOF
    interpreter = ["sh", "-c"]
    environment = {}
  }
  depends_on = [
    kops_cluster_updater.updater
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
    kops_cluster_updater.updater
  ]
}
