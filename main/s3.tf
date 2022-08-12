/**
 * File: /s3.tf
 * Project: main
 * File Created: 29-04-2022 14:41:49
 * Author: Clay Risser
 * -----
 * Last Modified: 12-08-2022 12:22:58
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "rancher2_app_v2" "s3" {
  chart_name    = "s3"
  chart_version = "0.0.1"
  cluster_id    = local.rancher_cluster_id
  name          = "s3"
  namespace     = "kube-system"
  repo_name     = rancher2_catalog_v2.risserlabs.name
  wait          = true
  values        = <<EOF
config:
  accessKey: ${var.aws_access_key_id}
  endpoint: s3.dualstack.${var.region}.amazonaws.com
  pathStyle: true
  region: ${var.region}
  secretKey: ${var.aws_secret_access_key}
  defaultBucket: ${var.bucket}
  defaultPrefix: default/${local.cluster_name}
EOF
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
