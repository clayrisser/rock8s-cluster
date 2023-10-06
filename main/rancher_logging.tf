/**
 * File: /rancher_logging.tf
 * Project: main
 * File Created: 05-10-2023 09:25:30
 * Author: Clay Risser
 * -----
 * BitSpur (c) Copyright 2021 - 2023
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

module "rancher-logging" {
  source             = "../modules/rancher_logging"
  enabled            = local.rancher_logging
  rancher_cluster_id = local.rancher_cluster_id
  rancher_project_id = local.rancher_project_id
  bucket             = aws_s3_bucket.loki[0].bucket
  endpoint           = "s3.${var.region}.amazonaws.com"
  region             = var.region
  access_key         = var.aws_access_key_id
  secret_key         = var.aws_secret_access_key
  grafana_repo       = rancher2_catalog_v2.grafana[0].name
  depends_on = [
    rancher2_namespace.rancher-monitoring
  ]
}
