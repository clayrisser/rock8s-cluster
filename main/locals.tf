/**
 * File: /locals.tf
 * Project: main
 * File Created: 14-04-2022 13:36:29
 * Author: Clay Risser
 * -----
 * Last Modified: 18-04-2022 11:48:35
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

locals {
  cluster_name = "${var.cluster_name}-${tostring(var.iteration)}"
  kubeconfig = jsonencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = module.eks.cluster_id
      cluster = {
        certificate-authority-data = module.eks.cluster_certificate_authority_data
        server                     = module.eks.cluster_endpoint
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = module.eks.cluster_id
        user    = "terraform"
      }
    }]
    users = [{
      name = "terraform"
      user = {
        token = data.aws_eks_cluster_auth.this.token
      }
    }]
  })
}
