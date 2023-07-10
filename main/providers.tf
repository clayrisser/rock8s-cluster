/**
 * File: /main/providers.tf
 * Project: kops
 * File Created: 14-04-2022 08:04:21
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:09:21
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

provider "flux" {}

provider "aws" {
  region = var.region
}

provider "helm" {
  kubernetes {
    host     = local.cluster_endpoint
    insecure = true
    exec {
      api_version = local.user_exec.api_version
      command     = local.user_exec.command
      args        = local.user_exec.args
    }
  }
}

provider "kubernetes" {
  host     = local.cluster_endpoint
  insecure = true
  exec {
    api_version = local.user_exec.api_version
    command     = local.user_exec.command
    args        = local.user_exec.args
  }
}

provider "kubectl" {
  host     = local.cluster_endpoint
  insecure = true
  exec {
    api_version = local.user_exec.api_version
    command     = local.user_exec.command
    args        = local.user_exec.args
  }
}

provider "kops" {
  state_store = local.kops_state_store
  aws {
    region = var.region
  }
}

provider "tls" {}
