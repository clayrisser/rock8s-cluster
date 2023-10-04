/**
 * File: /data.tf
 * Project: main
 * File Created: 27-09-2023 05:26:34
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

# data "aws_iam_role" "nodes" {
#   name = "nodes.${local.cluster_name}"
#   depends_on = [
#     kops_cluster_updater.updater
#   ]
# }

# data "aws_iam_role" "master" {
#   name = "master.${local.cluster_name}"
#   depends_on = [
#     kops_cluster_updater.updater
#   ]
# }

data "aws_caller_identity" "this" {}

data "kubernetes_service" "ingress-nginx-controller" {
  count = var.ingress_nginx ? 1 : 0
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  depends_on = [
    module.ingress-nginx
  ]
}

data "aws_route53_zone" "this" {
  name = var.dns_zone
}

data "aws_security_group" "nodes" {
  tags = {
    Name = "nodes.${local.cluster_name}"
  }
  depends_on = [
    kops_cluster_updater.updater
  ]
}
