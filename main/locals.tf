/**
 * File: /main/locals.tf
 * Project: kops
 * File Created: 14-04-2022 13:36:29
 * Author: Clay Risser
 * -----
 * Last Modified: 18-09-2022 11:28:07
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

locals {
  cluster_name         = "${var.cluster_prefix}-${tostring(var.iteration)}.${var.dns_zone}"
  cluster_entrypoint   = local.cluster_name
  kops_kubeconfig_file = "../artifacts/iam_kubeconfig"
  rancher_cluster_id   = "local"
  kops_state_store     = "s3://${aws_s3_bucket.main_bucket.bucket}/kops"
  public_api_ports     = [for port in split(",", var.public_api_ports) : parseint(port, 10)]
  public_nodes_ports   = [for port in split(",", var.public_nodes_ports) : parseint(port, 10)]
  cluster_endpoint     = "https://api.${var.cluster_prefix}-${tostring(var.iteration)}.${var.dns_zone}"
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
}
