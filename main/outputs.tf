/**
 * File: /outputs.tf
 * Project: main
 * File Created: 14-04-2022 08:17:04
 * Author: Clay Risser
 * -----
 * Last Modified: 11-06-2022 06:31:04
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

output "cluster_entrypoint" {
  value = local.cluster_entrypoint
}

output "cluster_endpoint" {
  value = local.cluster_endpoint
}
