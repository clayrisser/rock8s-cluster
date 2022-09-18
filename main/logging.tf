/**
 * File: /main/logging.tf
 * Project: kops
 * File Created: 18-09-2022 07:59:35
 * Author: Clay Risser
 * -----
 * Last Modified: 18-09-2022 09:59:22
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "rancher2_app_v2" "rancher_logging" {
  chart_name    = "rancher-logging"
  chart_version = "100.1.3+up3.17.7"
  cluster_id    = local.rancher_cluster_id
  name          = "rancher-logging"
  namespace     = rancher2_namespace.cattle_logging_system.name
  repo_name     = "rancher-charts"
  wait          = true
  values        = <<EOF
EOF
  depends_on    = []
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "rancher2_app_v2" "loki" {
  chart_name    = "loki"
  chart_version = "3.0.7"
  cluster_id    = local.rancher_cluster_id
  name          = "loki"
  namespace     = rancher2_namespace.loki.name
  repo_name     = rancher2_catalog_v2.grafana.name
  wait          = true
  values        = <<EOF
gateway:
  basicAuth:
    enabled: false
loki:
  auth_enabled: false
  commonConfig:
    replication_factor: 1
  storage:
    type: s3
    s3:
      endpoint: 's3.${var.region}.amazonaws.com'
      region: '${var.region}'
      secretAccessKey: '${var.aws_secret_access_key}'
      accessKeyId: '${var.aws_access_key_id}'
      insecure: false
    bucketNames:
      admin: '${aws_s3_bucket.loki_admin_bucket.bucket}'
      chunks: '${aws_s3_bucket.loki_chunks_bucket.bucket}'
      ruler: '${aws_s3_bucket.loki_chunks_bucket.bucket}'
EOF
  depends_on    = []
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "kubectl_manifest" "loki_output" {
  yaml_body = <<EOF
apiVersion: logging.banzaicloud.io/v1beta1
kind: ClusterOutput
metadata:
  name: loki-output
  namespace: cattle-logging-system
spec:
  loki:
    url: http://loki-gateway.loki.svc.cluster.local
    configure_kubernetes_labels: true
    buffer:
      timekey: 1m
      timekey_use_utc: true
      timekey_wait: 30s
EOF
  depends_on = [
    rancher2_app_v2.rancher_logging
  ]
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "rancher2_namespace" "cattle_logging_system" {
  name       = "cattle-logging-system"
  project_id = data.rancher2_project.system.id
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "rancher2_namespace" "loki" {
  name       = "loki"
  project_id = data.rancher2_project.system.id
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
