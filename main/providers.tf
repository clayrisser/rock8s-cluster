/**
 * File: /main.tf
 * Project: main
 * File Created: 14-04-2022 08:04:21
 * Author: Clay Risser
 * -----
 * Last Modified: 14-04-2022 08:20:40
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

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
