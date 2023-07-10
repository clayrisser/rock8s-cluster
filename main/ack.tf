/**
 * File: /main/ack.tf
 * Project: kops
 * File Created: 29-06-2023 12:07:20
 * Author: Clay Risser
 * -----
 * Last Modified: 09-07-2023 06:53:22
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022 - 2023
 */

locals {
  ack_service_versions = {
    "iam" = "1.2.2",
    "s3"  = "1.0.4",
  }
}

module "aws-creds" {
  source             = "../modules/helm_release"
  enabled            = var.ack_services != ""
  chart_version      = "0.0.1"
  name               = "aws-creds"
  repo               = module.rock8s-repo.repo
  chart_name         = "aws-creds"
  namespace          = "ack-system"
  rancher_project_id = local.rancher_project_id
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
aws:
  accessKey: ${var.aws_access_key_id}
  secretKey: ${var.aws_secret_access_key}
EOF
  depends_on = [
    module.integration-operator
  ]
}

resource "helm_release" "ack" {
  for_each         = toset(split(",", var.ack_services))
  version          = local.ack_service_versions[each.value]
  name             = "ack-${each.value}-controller"
  repository       = "oci://public.ecr.aws/aws-controllers-k8s"
  chart            = "${each.value}-chart"
  namespace        = "ack-system"
  create_namespace = false
  values = [<<EOF
aws:
  region: ${var.region}
  credentials:
    secretName: aws-creds
    secretKey: credentials
    profile: default
EOF
  ]
  depends_on = [
    module.aws-creds
  ]
  lifecycle {
    prevent_destroy = false
  }
}
