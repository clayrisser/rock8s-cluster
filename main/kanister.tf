/**
 * File: /main/kanister.tf
 * Project: kops
 * File Created: 21-04-2022 08:39:20
 * Author: Clay Risser
 * -----
 * Last Modified: 29-09-2022 05:36:57
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "kanister" {
  source             = "../modules/helm_release"
  chart_name         = "kanister"
  chart_version      = "0.71.0"
  name               = "kanister"
  repo               = module.risserlabs_repo.repo
  create_namespace   = true
  namespace          = "kanister"
  rancher_project_id = local.rancher_project_id
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
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
    module.integration_operator,
    module.helm_operator
  ]
}
