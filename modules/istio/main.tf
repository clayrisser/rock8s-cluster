resource "helm_release" "base" {
  count            = var.enabled ? 1 : 0
  name             = "istio-base"
  version          = var.chart_version
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  namespace        = var.namespace
  create_namespace = true
  values = [<<EOF
defaultRevision: default
EOF
  ]
}

resource "helm_release" "cni" {
  count      = var.enabled ? 1 : 0
  name       = "istio-cni"
  version    = var.chart_version
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "cni"
  namespace  = "kube-system"
  values = [<<EOF
cni:
  chained: true
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: eks.amazonaws.com/compute-type
                operator: NotIn
                values:
                  - fargate
EOF
  ]
  depends_on = [
    helm_release.base
  ]
}

resource "helm_release" "istiod" {
  count            = var.enabled ? 1 : 0
  name             = "istiod"
  version          = var.chart_version
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "istiod"
  namespace        = var.namespace
  create_namespace = true
  values = [<<EOF
istio_cni:
  enabled: true
  chained: true
EOF
    ,
    var.values
  ]
  depends_on = [
    helm_release.cni
  ]
}

resource "helm_release" "kiali" {
  count      = var.enabled ? 1 : 0
  name       = "kiali-server"
  version    = "1.73.0"
  repository = "https://kiali.org/helm-charts"
  chart      = "kiali-server"
  namespace  = var.namespace
  values = [<<EOF
auth:
  strategy: anonymous
EOF
  ]
  depends_on = [
    helm_release.istiod
  ]
}
