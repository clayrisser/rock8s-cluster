/**
 * File: /main/velero.tf
 * Project: kops
 * File Created: 21-04-2022 08:53:47
 * Author: Clay Risser
 * -----
 * Last Modified: 27-09-2022 12:45:59
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "velero" {
  source             = "../modules/helm_release"
  chart_name         = "velero"
  chart_version      = "2.14.1"
  name               = "velero"
  repo               = rancher2_catalog_v2.risserlabs.name
  namespace          = "velero"
  create_namespace   = true
  rancher_project_id = data.rancher2_project.system.id
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
config:
  allowIntegration: true
  s3:
    integration: kube-system
    bucket: ${aws_s3_bucket.main.bucket}
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
    module.integration_operator,
    module.helm_controller,
    module.s3
  ]
}
