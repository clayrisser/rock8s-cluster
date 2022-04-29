/**
 * File: /providers.tf
 * Project: main
 * File Created: 14-04-2022 08:04:21
 * Author: Clay Risser
 * -----
 * Last Modified: 29-04-2022 15:45:17
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
    # client_certificate     = data.kops_kube_config.this.client_cert
    # client_key             = data.kops_kube_config.this.client_key
    config_path    = local.kops_kubeconfig_file
    config_context = local.cluster_name
    # cluster_ca_certificate = local.k8s.cluster_ca_certificate
    # host                   = local.k8s.server
    # password               = local.k8s.password
    # username               = local.k8s.username
  }
}

provider "kubernetes" {
  # client_certificate     = data.kops_kube_config.this.client_cert
  # client_key             = data.kops_kube_config.this.client_key
  config_path    = local.kops_kubeconfig_file
  config_context = local.cluster_name
  # cluster_ca_certificate = local.k8s.cluster_ca_certificate
  # host                   = local.k8s.server
  # password               = local.k8s.password
  # username               = local.k8s.username
}

provider "kubectl" {
  # client_certificate     = data.kops_kube_config.this.client_cert
  # client_key             = data.kops_kube_config.this.client_key
  config_path    = local.kops_kubeconfig_file
  config_context = local.cluster_name
  # load_config_file       = false
  # cluster_ca_certificate = local.k8s.cluster_ca_certificate
  # host                   = local.k8s.server
  # password               = local.k8s.password
  # username               = local.k8s.username
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
