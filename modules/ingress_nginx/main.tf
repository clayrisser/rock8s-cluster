resource "helm_release" "this" {
  count            = var.enabled ? 1 : 0
  name             = "ingress-nginx"
  version          = var.chart_version
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = var.namespace
  create_namespace = true
  values = [<<EOF
tcp: {}
udp: {}
controller:
  watchIngressWithoutClass: true
  hostPort:
    enabled: false
    ports: ${jsonencode({ for port in var.ingress_ports : port == "80" ? "http" : port == "443" ? "https" : port => port })}
  admissionWebhooks:
    enabled: false
  ingressClassResource:
    name: nginx
    default: true
  topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: topology.kubernetes.io/zone
      whenUnsatisfiable: ScheduleAnyway
      labelSelector:
        matchLabels:
          app.kubernetes.io/instance: ingress-nginx-external
    - maxSkew: 1
      topologyKey: kubernetes.io/hostname
      whenUnsatisfiable: ScheduleAnyway
      labelSelector:
        matchLabels:
          app.kubernetes.io/instance: ingress-nginx-external
EOF
    ,
    var.replicas > 0 && var.security_group != "" ? <<EOF
controller:
  replicaCount: 2
  minAvailable: 2
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
      service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
      service.beta.kubernetes.io/aws-load-balancer-security-groups: ${var.security_group}
      service.beta.kubernetes.io/aws-load-balancer-manage-backend-security-group-rules: true
    loadBalancerClass: service.k8s.aws/nlb
    enabled: true
    type: LoadBalancer
    ports: ${jsonencode({ for port in var.ingress_ports : port == "80" ? "http" : port == "443" ? "https" : port => port })}
EOF
    : <<EOF
controller:
  kind: DaemonSet
EOF
    ,
    var.values
  ]
}

resource "null_resource" "wait-for-ingress-nginx" {
  count = var.enabled ? 1 : 0
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
      CLUSTER_ENTRYPOINT = var.cluster_entrypoint
    }
  }
  depends_on = [
    helm_release.this
  ]
}

data "kubernetes_service" "ingress-nginx" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  depends_on = [
    helm_release.this
  ]
}
