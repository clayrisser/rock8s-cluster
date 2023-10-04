/**
 * File: /providers.tf
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
  state_store   = local.kops_state_store
  feature_flags = ["Karpenter"]
  aws {
    region = var.region
  }
}

provider "tls" {}

provider "kustomization" {
  context        = "terraform"
  kubeconfig_raw = local.kubeconfig
}
