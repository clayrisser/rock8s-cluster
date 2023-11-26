/**
 * File: /rancher.tf
 * Project: main
 * File Created: 03-10-2023 20:24:13
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

module "rancher" {
  source                 = "../modules/rancher"
  enabled                = local.rancher
  kubeconfig             = local.kubeconfig
  letsencrypt_email      = var.email
  rancher_admin_password = var.rancher_admin_password
  rancher_cluster_id     = local.rancher_cluster_id
  rancher_hostname       = try(aws_route53_record.cluster[0].name, "")
}

provider "rancher2" {
  api_url   = module.rancher.api_url
  token_key = module.rancher.token_key != "" ? module.rancher.token_key : ""
}

resource "rancher2_catalog_v2" "grafana" {
  count      = local.rancher ? 1 : 0
  cluster_id = local.rancher_cluster_id
  name       = "grafana"
  url        = "https://grafana.github.io/helm-charts"
  depends_on = [
    module.rancher
  ]
}


resource "rancher2_catalog_v2" "rock8s" {
  count      = local.rancher ? 1 : 0
  cluster_id = local.rancher_cluster_id
  name       = "rock8s"
  url        = "https://charts.rock8s.com"
  depends_on = [
    module.rancher
  ]
}
