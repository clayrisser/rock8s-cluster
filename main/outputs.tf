/**
 * File: /main/outputs.tf
 * Project: kops
 * File Created: 14-04-2022 08:17:04
 * Author: Clay Risser
 * -----
 * Last Modified: 28-10-2022 22:19:35
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
