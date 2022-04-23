/**
 * File: /rancher_monitoring.tf
 * Project: main
 * File Created: 20-04-2022 13:40:49
 * Author: Clay Risser
 * -----
 * Last Modified: 21-04-2022 09:48:09
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "rancher2_namespace" "cattle_monitoring_system" {
  name       = "cattle-monitoring-system"
  project_id = data.rancher2_project.system.id
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "rancher2_app_v2" "rancher-monitoring" {
  chart_name    = "rancher-monitoring"
  chart_version = "100.1.2+up19.0.3"
  cluster_id    = local.cluster_id
  name          = "rancher-monitoring"
  namespace     = rancher2_namespace.cattle_monitoring_system.name
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
  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      annotations
    ]
  }
}