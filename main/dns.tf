/**
 * File: /dns.tf
 * Project: main
 * File Created: 27-09-2023 05:26:35
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

data "aws_route53_zone" "this" {
  name = var.dns_zone
}

resource "aws_route53_record" "cluster" {
  count   = var.ingress_nginx ? 1 : 0
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.cluster_entrypoint
  type    = "CNAME"
  ttl     = "200"
  records = [module.ingress-nginx.hostname]
  depends_on = [
    null_resource.wait-for-cluster,
    module.kyverno
  ]
}
