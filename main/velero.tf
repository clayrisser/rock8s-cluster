/**
 * File: /main/velero.tf
 * Project: kops
 * File Created: 21-04-2022 08:53:47
 * Author: Clay Risser
 * -----
 * Last Modified: 18-09-2022 08:49:35
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "rancher2_app_v2" "velero" {
  chart_name    = "velero"
  chart_version = "2.14.1"
  cluster_id    = local.rancher_cluster_id
  name          = "velero"
  namespace     = rancher2_namespace.velero.name
  repo_name     = rancher2_catalog_v2.risserlabs.name
  wait          = true
  values        = <<EOF
config:
  allowIntegration: true
  s3:
    integration: kube-system
    bucket: ${aws_s3_bucket.main_bucket.bucket}
    prefix: velero
velero:
  backupsEnabled: true
  deployRestic: true
  snapshotsEnabled: true
  metrics:
    enabled: true
  configuration:
    provider: aws
    volumeSnapshotLocation:
      provider: velero.io/aws
      config:
        region: ${var.region}
EOF
  depends_on = [
    rancher2_app_v2.integration_operator,
    rancher2_app_v2.helm_controller,
    rancher2_app_v2.s3
  ]
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "rancher2_namespace" "velero" {
  name       = "velero"
  project_id = data.rancher2_project.system.id
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
