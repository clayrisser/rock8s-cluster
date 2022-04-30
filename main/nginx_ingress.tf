/**
 * File: /nginx_ingress.tf
 * Project: eks
 * File Created: 12-02-2022 12:16:54
 * Author: Clay Risser
 * -----
 * Last Modified: 30-04-2022 16:46:48
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "helm_release" "ingress_nginx" {
  version          = "4.0.17"
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  values = [<<EOF
tcp: {}
udp: {}
controller:
  watchIngressWithoutClass: true
  kind: DaemonSet
  admissionWebhooks:
    enabled: false
  ingressClassResource:
    name: nginx
    default: true
  service:
    enabled: true
    type: LoadBalancer
    ports:
      http: 80
      https: 443
      ssh: 22
  hostPort:
    enabled: true
    ports:
      http: 80
      https: 443
      ssh: 22
EOF
  ]
  depends_on = [
    null_resource.wait_for_nodes
  ]
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "time_sleep" "wait_for_ingress_nginx" { // TODO: imporove healthcheck
  depends_on = [
    helm_release.ingress_nginx
  ]
  create_duration = "60s"
}
