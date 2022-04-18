/**
 * File: /nginx_ingress.tf
 * Project: eks
 * File Created: 12-02-2022 12:16:54
 * Author: Clay Risser
 * -----
 * Last Modified: 17-04-2022 05:56:40
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

locals {
  nginx_ingress_chart_version = "4.0.17"
  nginx_ingress_namespace     = "ingress-nginx"
}

resource "helm_release" "ingress_nginx" {
  version          = local.nginx_ingress_chart_version
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = local.nginx_ingress_namespace
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
}

resource "time_sleep" "wait_for_ingress_nginx" {
  depends_on = [
    helm_release.ingress_nginx
  ]
  create_duration = "60s"
}

data "kubernetes_service" "ingress_nginx_controller" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  depends_on = [
    time_sleep.wait_for_ingress_nginx
  ]
}