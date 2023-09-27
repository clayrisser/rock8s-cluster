/**
 * File: /main.tf
 * Project: external_dns
 * File Created: 27-09-2023 06:47:50
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

resource "helm_release" "this" {
  count            = var.enabled ? 1 : 0
  name             = "external-dns"
  version          = var.chart_version
  repository       = "https://kubernetes-sigs.github.io/external-dns"
  chart            = "external-dns"
  namespace        = var.namespace
  create_namespace = true
  values = [<<EOF
provider: cloudflare
cloudflare:
  apiKey: ${var.cloudflare_api_key}
  email: ${var.cloudflare_email}
  proxied: false
  sources:
    - ingress
EOF
    ,
    var.values
  ]
}
