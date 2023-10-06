/**
 * File: /rancher_istio.tf
 * Project: main
 * File Created: 04-10-2023 16:02:55
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

module "rancher-istio" {
  source             = "../modules/rancher_istio"
  enabled            = local.rancher_istio
  rancher_cluster_id = local.rancher_cluster_id
  rancher_project_id = local.rancher_project_id
  depends_on = [
    module.rancher-monitoring
  ]
}
