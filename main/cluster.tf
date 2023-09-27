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

resource "kops_cluster" "this" {
  name               = local.cluster_name
  admin_ssh_key      = tls_private_key.admin.public_key_openssh
  ssh_key_name       = aws_key_pair.node.key_name
  kubernetes_version = "v1.26.8"
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
    rbac {}
  }
  iam {
    legacy                                   = false
    allow_container_registry                 = true
    use_service_account_external_permissions = false
    dynamic "service_account_external_permissions" {
      for_each = [for namespace in local.elevated_namespaces : { ns = namespace, policies = local.elevated_policies }]
      content {
        name      = element(split(":", service_account_external_permissions.value.ns), 1)
        namespace = element(split(":", service_account_external_permissions.value.ns), 0)
        aws {
          policy_ar_ns = service_account_external_permissions.value.policies
        }
      }
    }
  }
  external_policies {
    key   = "master"
    value = local.external_policies
  }
  external_policies {
    key   = "node"
    value = local.external_policies
  }
  service_account_issuer_discovery {
    enable_aws_oidc_provider = true
    discovery_store          = "s3://${aws_s3_bucket.oidc.bucket}"
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
  }
  etcd_cluster {
    name = "events"
    member {
      name           = "master-0"
      instance_group = "master-0"
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
  aws_load_balancer_controller {
    enabled = true
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
  cloud_labels = local.tags
  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      admin_ssh_key,
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
  machine_type               = "c5.xlarge"
  subnets                    = [data.aws_subnet.public[0].id]
  additional_security_groups = [aws_security_group.api.id]
  root_volume_size           = 32
  lifecycle {
    prevent_destroy = false
  }
}

resource "kops_instance_group" "core-0" {
  cluster_name               = kops_cluster.this.id
  name                       = "core-0"
  autoscale                  = true
  role                       = "Node"
  min_size                   = 3
  max_size                   = 3
  machine_type               = "t3.medium"
  subnets                    = [data.aws_subnet.public[0].id]
  additional_security_groups = [aws_security_group.nodes.id]
  root_volume_size           = 32
  dynamic "additional_user_data" {
    for_each = local.node_additional_user_data
    content {
      name    = additional_user_data.value["name"]
      type    = additional_user_data.value["type"]
      content = additional_user_data.value["content"]
    }
  }
  lifecycle {
    prevent_destroy = false
  }
}

resource "kops_cluster_updater" "updater" {
  cluster_name = kops_cluster.this.id
  keepers = {
    cluster  = kops_cluster.this.revision
    master-0 = kops_instance_group.master-0.revision
    core-0   = kops_instance_group.core-0.revision
  }
  rolling_update {
    skip                = true
    fail_on_drain_error = true
    fail_on_validate    = false
    validate_count      = 1
  }
  validate {
    skip = false
  }
  lifecycle {
    prevent_destroy = false
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
    interpreter = ["sh", "-c"]
    environment = {
      KUBECONFIG = local.kubeconfig
    }
  }
  depends_on = [
    kops_cluster_updater.updater
  ]
}
