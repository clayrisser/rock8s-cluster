/**
 * File: /main/kanister.tf
 * Project: kops
 * File Created: 21-04-2022 08:39:20
 * Author: Clay Risser
 * -----
 * Last Modified: 23-09-2022 10:31:36
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "rancher2_app_v2" "kanister" {
  chart_name    = "kanister"
  chart_version = "0.71.0"
  cluster_id    = local.rancher_cluster_id
  name          = "kanister"
  namespace     = rancher2_namespace.kanister.name
  repo_name     = rancher2_catalog_v2.risserlabs.name
  wait          = true
  values        = <<EOF
config:
  s3:
    accessKey: '${var.aws_access_key_id}'
    bucket: '${aws_s3_bucket.main.bucket}'
    endpoint: 's3.${var.region}.amazonaws.com'
    pathStyle: true
    prefix: kanister
    region: '${var.region}'
    secretKey: '${var.aws_secret_access_key}'
EOF
  depends_on = [
    rancher2_app_v2.integration_operator,
    rancher2_app_v2.helm_operator
  ]
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "rancher2_namespace" "kanister" {
  name       = "kanister"
  project_id = data.rancher2_project.system.id
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
