resource "rancher2_namespace" "this" {
  count      = var.enabled ? 1 : 0
  name       = var.namespace
  project_id = var.rancher_project_id
}

resource "rancher2_app_v2" "this" {
  count         = var.enabled ? 1 : 0
  chart_name    = "rancher-istio"
  chart_version = var.chart_version
  cluster_id    = var.rancher_cluster_id
  name          = "rancher-istio"
  namespace     = rancher2_namespace.this[0].name
  repo_name     = "rancher-charts"
  wait          = true
  values        = <<EOF
cni:
  enabled: true
egressGateways:
  enabled: true
tracing:
  enabled: true
EOF
}
