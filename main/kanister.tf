/**
 * File: /main/kanister.tf
 * Project: kops
 * File Created: 21-04-2022 08:39:20
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:07:13
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

module "kanister-s3" {
  source             = "../modules/helm_release"
  enabled            = local.kanister
  chart_name         = "s3"
  chart_version      = "0.0.1"
  name               = "kanister-s3"
  repo               = module.rock8s-repo.repo
  namespace          = "kanister"
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
bucket:
  name: kanister
  encrypted: true
config:
  awsCreds: ack-system
EOF
  depends_on = [
    helm_release.ack,
    module.integration-operator,
  ]
}

module "kanister-operator" {
  source             = "../modules/helm_release"
  enabled            = local.kanister
  chart_name         = "kanister-operator"
  chart_version      = "0.93.0"
  name               = "kanister-operator"
  repo               = module.rock8s-repo.repo
  namespace          = "kanister"
  rancher_project_id = local.rancher_project_id
  rancher_cluster_id = local.rancher_cluster_id
  depends_on = [
    kubectl_manifest.flux-install,
    module.easy-olm-operator,
    module.integration-operator,
  ]
}

module "kanister" {
  source             = "../modules/helm_release"
  enabled            = local.kanister
  chart_name         = "kanister"
  chart_version      = "0.93.0"
  name               = "kanister"
  repo               = module.rock8s-repo.repo
  namespace          = "kanister"
  rancher_project_id = local.rancher_project_id
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
config:
  s3:
    integration: kanister
EOF
  depends_on = [
    module.kanister-operator,
    module.kanister-s3
  ]
}
