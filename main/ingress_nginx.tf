/**
 * File: /main/ingress_nginx.tf
 * Project: kops
 * File Created: 27-09-2022 12:47:58
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:06:05
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

resource "helm_release" "ingress-nginx" {
  count            = var.ingress_nginx ? 1 : 0
  name             = "ingress-nginx"
  version          = "4.7.0"
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
    null_resource.wait-for-nodes
  ]
  lifecycle {
    prevent_destroy = false
  }
}

resource "null_resource" "wait-for-ingress-nginx" {
  count = var.ingress_nginx ? 1 : 0
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
    helm_release.ingress-nginx,
    aws_route53_record.cluster
  ]
}
