/**
 * File: /outputs.tf
 * Project: main
 * File Created: 14-04-2022 08:17:04
 * Author: Clay Risser
 * -----
 * Last Modified: 24-04-2022 10:19:40
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  # value       = module.eks.cluster_endpoint
  value = ""
}
