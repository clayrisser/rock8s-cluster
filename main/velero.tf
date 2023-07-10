/**
 * File: /main/velero.tf
 * Project: kops
 * File Created: 21-04-2022 08:53:47
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:06:44
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

module "velero-s3" {
  source             = "../modules/helm_release"
  enabled            = local.velero
  chart_name         = "s3"
  chart_version      = "0.0.1"
  name               = "velero-s3"
  repo               = module.rock8s-repo.repo
  namespace          = "velero"
  rancher_project_id = local.rancher_project_id
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
bucket:
  name: velero
  encrypted: true
config:
  awsCreds: ack-system
EOF
  depends_on = [
    helm_release.ack,
    module.integration-operator
  ]
}

module "velero" {
  source             = "../modules/helm_release"
  enabled            = local.velero
  chart_name         = "velero"
  chart_version      = "2.14.1"
  name               = "velero"
  repo               = module.rock8s-repo.repo
  namespace          = "velero"
  rancher_project_id = local.rancher_project_id
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
config:
  allowIntegration: true
  s3:
    integration: velero
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
    module.integration-operator,
    kubectl_manifest.flux-install,
    module.velero-s3
  ]
}
