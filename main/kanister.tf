/**
 * File: /kanister.tf
 * Project: main
 * File Created: 21-04-2022 08:39:20
 * Author: Clay Risser
 * -----
 * Last Modified: 21-04-2022 08:57:13
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "rancher2_app_v2" "kanister" {
  provider      = rancher2.main
  chart_name    = "kanister"
  chart_version = "0.0.1"
  cluster_id    = local.cluster_id
  name          = "kanister"
  namespace     = rancher2_namespace.kanister.name
  repo_name     = rancher2_catalog_v2.bitspur.name
  wait          = true
  depends_on    = []
  values        = <<EOF
config:
  s3:
    accessKey: '${var.aws_access_key_id}'
    bucket: '${var.bucket == "" ? var.cluster_name : var.bucket}'
    endpoint: 's3.${var.region}.amazonaws.com'
    pathStyle: true
    prefix: 'kanister/${var.cluster_name}'
    region: '${var.region}'
    secretKey: '${var.aws_secret_access_key}'
EOF
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "rancher2_namespace" "kanister" {
  provider   = rancher2.main
  name       = "kanister"
  project_id = data.rancher2_project.system.id
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
