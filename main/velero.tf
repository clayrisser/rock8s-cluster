/**
 * File: /main/velero.tf
 * Project: kops
 * File Created: 21-04-2022 08:53:47
 * Author: Clay Risser
 * -----
 * Last Modified: 27-06-2023 15:39:42
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

module "velero" {
  source             = "../modules/helm_release"
  enabled            = local.velero
  chart_name         = "velero"
  chart_version      = "2.14.1"
  name               = "velero"
  repo               = module.rock8s_repo.repo
  namespace          = "velero"
  create_namespace   = true
  rancher_project_id = local.rancher_project_id
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
    kubectl_manifest.flux_install,
    module.s3
  ]
}
