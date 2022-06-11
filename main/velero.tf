/**
 * File: /velero.tf
 * Project: main
 * File Created: 21-04-2022 08:53:47
 * Author: Clay Risser
 * -----
 * Last Modified: 11-06-2022 05:17:44
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
  accessKeyId: ${var.aws_access_key_id}
  secretAccessKey: ${var.aws_secret_access_key}
velero:
  backupsEnabled: true
  deployRestic: true
  snapshotsEnabled: true
  metrics:
    enabled: true
  configuration:
    provider: aws
    backupStorageLocation:
      bucket: ${var.bucket}
      prefix: velero/${local.cluster_name}
      config:
        profile: default
        region: ${var.region}
        s3Url:
    volumeSnapshotLocation:
      provider: velero.io/aws
      config:
        region: ${var.region}
EOF
  depends_on = [
    rancher2_app_v2.integration_operator
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
