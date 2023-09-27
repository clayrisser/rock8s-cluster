resource "helm_release" "this" {
  count            = var.enabled ? 1 : 0
  repository       = "https://fluxcd-community.github.io/helm-charts"
  version          = var.chart_version
  chart            = "flux2"
  name             = "flux2"
  namespace        = var.namespace
  create_namespace = true
  values = [<<EOF
EOF
    ,
    var.values
  ]
}
