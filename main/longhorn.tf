/**
 * File: /main/longhorn.tf
 * Project: kops
 * File Created: 13-10-2022 02:34:15
 * Author: Clay Risser
 * -----
 * Last Modified: 13-10-2022 05:57:07
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

# module "rancher_monitoring" {
#   source             = "../modules/helm_release"
#   enabled            = local.longhorn
#   chart_name         = "longhorn"
#   chart_version      = "100.1.2+up19.0.3"
#   name               = "longhorn"
#   repo               = "longhorn"
#   namespace          = "longhorn"
#   create_namespace   = true
#   rancher_cluster_id = local.rancher_cluster_id
#   values             = <<EOF
# EOF
# }
