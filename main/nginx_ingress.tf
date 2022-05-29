/**
 * File: /nginx_ingress.tf
 * Project: eks
 * File Created: 12-02-2022 12:16:54
 * Author: Clay Risser
 * -----
 * Last Modified: 29-05-2022 03:36:40
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

resource "null_resource" "wait_for_ingress_nginx" {
  provisioner "local-exec" {
    command     = <<EOF
s=5
while [ "$s" -ge "5" ]; do
  _s=$(echo $(curl -v $CLUSTER_ENTRYPOINT 2>&1 | grep -E '^< HTTP') | awk '{print $3}' | head -c 1)
  if [ "$_s" != "" ]; then
    s=$_s
  fi
  if [ "$s" -ge "5" ]; then
    sleep 10
  fi
done
EOF
    interpreter = ["sh", "-c"]
    environment = {
      CLUSTER_ENTRYPOINT = local.cluster_entrypoint
    }
  }
  depends_on = [
    helm_release.ingress_nginx,
    aws_route53_record.cluster
  ]
}
