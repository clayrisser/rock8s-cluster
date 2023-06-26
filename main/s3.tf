/**
 * File: /main/s3.tf
 * Project: kops
 * File Created: 29-04-2022 14:41:49
 * Author: Clay Risser
 * -----
 * Last Modified: 26-06-2023 07:20:39
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "s3" {
  source             = "../modules/helm_release"
  enabled            = local.s3
  chart_name         = "s3"
  chart_version      = "0.0.1"
  name               = "s3"
  repo               = module.rock8s_repo.repo
  namespace          = "kube-system"
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
config:
  s3:
    accessKey: ${var.aws_access_key_id}
    defaultBucket: '${aws_s3_bucket.main.bucket}'
    defaultPrefix: default/${local.cluster_name}
    endpoint: s3.dualstack.${var.region}.amazonaws.com
    pathStyle: true
    region: ${var.region}
    secretKey: ${var.aws_secret_access_key}
    tls: true
EOF
  depends_on = [
    module.integration_operator
  ]
}
