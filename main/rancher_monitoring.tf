/**
 * File: /main/rancher_monitoring.tf
 * Project: kops
 * File Created: 20-04-2022 13:40:49
 * Author: Clay Risser
 * -----
 * Last Modified: 17-09-2022 06:55:25
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "rancher2_app_v2" "rancher_monitoring" {
  chart_name    = "rancher-monitoring"
  chart_version = "100.1.2+up19.0.3"
  cluster_id    = local.rancher_cluster_id
  name          = "rancher-monitoring"
  namespace     = "cattle-monitoring-system"
  repo_name     = "rancher-charts"
  wait          = true
  values        = <<EOF
grafana:
  sidecar:
    image:
      repository: rancher/kiwigrid-k8s-sidecar
      tag: 1.1.0
    dashboards:
      searchNamespace: cattle-dashboards
  persistence:
    size: 10Gi
    storageClassName: gp2
    type: pvc
    accessModes:
      - ReadWriteOnce
prometheus:
  prometheusSpec:
    scrapeInterval: 2m
    evaluationInterval: 2m
    retention: 1d
    retentionSize: 10GiB
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: gp2
          volumeMode: Filesystem
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 10Gi
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
            - matchExpressions:
                - key: kubernetes.io/arch
                  operator: In
                  values:
                    - amd64
prometheusOperator:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: kubernetes.io/arch
                operator: In
                values:
                  - amd64
prometheus-adapter:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: kubernetes.io/arch
                operator: In
                values:
                  - amd64
kube-state-metrics:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: kubernetes.io/arch
                operator: In
                values:
                  - amd64
EOF
  depends_on = [
    rancher2_app_v2.integration_operator,
    rancher2_app_v2.helm_operator
  ]
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
