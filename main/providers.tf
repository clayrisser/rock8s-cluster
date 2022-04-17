/**
 * File: /providers.tf
 * Project: main
 * File Created: 14-04-2022 08:04:21
 * Author: Clay Risser
 * -----
 * Last Modified: 17-04-2022 03:23:15
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
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    host                   = module.eks.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubernetes" {
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  host                   = module.eks.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "kubectl" {
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  host                   = module.eks.cluster_endpoint
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}
