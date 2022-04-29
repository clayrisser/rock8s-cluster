/**
 * File: /providers.tf
 * Project: main
 * File Created: 14-04-2022 08:04:21
 * Author: Clay Risser
 * -----
 * Last Modified: 29-04-2022 17:12:53
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

provider "flux" {}

provider "aws" {
  region = var.region
}

provider "helm" {
  kubernetes {
    host     = local.cluster_endpoint
    insecure = true
    exec     = local.user_exec
  }
}

provider "kubernetes" {
  host     = local.cluster_endpoint
  insecure = true
  exec     = local.user_exec
}

provider "kubectl" {
  host     = local.cluster_endpoint
  insecure = true
  exec     = local.user_exec
}

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

provider "gitlab" {
  token = var.gitlab_token
}

provider "kops" {
  state_store = local.kops_state_store
  aws {
    region = var.region
  }
}

provider "tls" {}
