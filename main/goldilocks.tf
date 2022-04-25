/**
 * File: /goldilocks.tf
 * Project: main
 * File Created: 20-04-2022 10:21:22
 * Author: Clay Risser
 * -----
 * Last Modified: 24-04-2022 08:54:45
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

# locals {
#   goldilocks_version = "6.1.1"
# }

# resource "helm_release" "goldilocks" {
#   version          = local.goldilocks_version
#   name             = "goldilocks"
#   repository       = "https://charts.fairwinds.com/stable"
#   chart            = "goldilocks"
#   namespace        = "goldilocks"
#   create_namespace = true
#   values = [<<EOF
# vpa:
#   enabled: true
#   updater:
#     enabled: false
# dashboard:
#   excludeContainers: 'linkerd-proxy,istio-proxy'
# EOF
#   ]
#   depends_on = [
#     null_resource.wait_for_nodes
#   ]
# }
