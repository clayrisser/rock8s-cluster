/**
 * File: /main.tf
 * Project: kubernetes_resources
 * File Created: 14-04-2022 07:57:02
 * Author: Clay Risser
 * -----
 * Last Modified: 21-04-2022 03:55:22
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "null_resource" "create_resource" {
  for_each = { for value in var.resources : value => value }
  provisioner "local-exec" {
    command     = <<EOF
kubectl --kubeconfig <(echo $KUBECONFIG) apply -f $RESOURCE
EOF
    interpreter = ["sh", "-c"]
    environment = {
      KUBECONFIG = var.kubeconfig
      RESOURCE   = each.value
    }
  }
}
