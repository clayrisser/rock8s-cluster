/**
 * File: /integration_operator.tf
 * Project: main
 * File Created: 21-04-2022 09:05:39
 * Author: Clay Risser
 * -----
 * Last Modified: 24-04-2022 11:09:15
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

# resource "rancher2_app_v2" "integration_operator" {
#   chart_name    = "integration-operator"
#   chart_version = "0.1.1"
#   cluster_id    = local.rancher_cluster_id
#   name          = "integration-operator"
#   namespace     = "kube-system"
#   repo_name     = rancher2_catalog_v2.bitspur.name
#   wait          = true
#   values        = <<EOF
# {}
# EOF
#   depends_on = [
#     rancher2_app_v2.integration_operator
#   ]
#   lifecycle {
#     prevent_destroy = false
#     ignore_changes  = []
#   }
# }
