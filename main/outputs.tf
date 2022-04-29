/**
 * File: /outputs.tf
 * Project: main
 * File Created: 14-04-2022 08:17:04
 * Author: Clay Risser
 * -----
 * Last Modified: 29-04-2022 17:01:27
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

output "cluster_endpoint" {
  value = local.cluster_endpoint
}
