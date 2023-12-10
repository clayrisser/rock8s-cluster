/**
 * File: /locals.tf
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

locals {
  cluster_name         = "${var.cluster_prefix}-${tostring(var.iteration)}.${var.dns_zone}"
  user_name            = "${var.cluster_prefix}.${var.dns_zone}"
  cluster_entrypoint   = local.cluster_name
  kops_kubeconfig_file = "../artifacts/iam_kubeconfig"
  rancher_cluster_id   = var.rancher ? "local" : ""
  rancher_project_id   = var.rancher ? module.rancher.system_project_id : ""
  kops_state_store     = "s3://${aws_s3_bucket.main.bucket}/kops"
  public_api_ports     = [for port in split(",", var.public_api_ports) : port]
  public_nodes_ports   = [for port in split(",", var.public_nodes_ports) : port]
  ingress_ports        = [for port in split(",", var.ingress_ports) : port]
  cluster_endpoint     = "https://api.${local.cluster_name}"
  oidc_provider        = "${aws_s3_bucket.oidc.bucket}.s3.${var.region}.amazonaws.com"
  user_exec = {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws-iam-authenticator"
    args = [
      "token",
      "-i",
      local.cluster_name,
      "-r",
      aws_iam_role.admin.arn
    ]
  }
  kubeconfig = jsonencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = "terraform"
      cluster = {
        insecure-skip-tls-verify = true,
        server                   = local.cluster_endpoint
      }
    }]
    users = [{
      name = "terraform"
      user = {
        exec = {
          apiVersion = local.user_exec.api_version
          command    = local.user_exec.command
          args       = local.user_exec.args
        }
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = "terraform"
        user    = "terraform"
      }
    }]
  })
  tags = {
    Cluster = local.cluster_name
  }
  kanister           = var.kanister && var.flux && var.olm
  longhorn           = var.longhorn && local.rancher
  rancher            = var.rancher && var.ingress_nginx && var.kyverno
  rancher_istio      = var.rancher_istio && local.rancher_monitoring
  rancher_logging    = var.rancher_logging && local.rancher_monitoring
  rancher_monitoring = var.rancher_monitoring && local.rancher
  tempo              = var.tempo && local.rancher_logging
  thanos             = local.rancher_monitoring && var.thanos
}
