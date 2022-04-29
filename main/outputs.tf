/**
 * File: /outputs.tf
 * Project: main
 * File Created: 14-04-2022 08:17:04
 * Author: Clay Risser
 * -----
 * Last Modified: 29-04-2022 15:15:34
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

output "cluster_endpoint" {
  value = local.k8s.server
}

# output "client_password" {
#   value = local.k8s.password
# }
