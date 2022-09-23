/**
 * File: /main/rancher_monitoring.tf
 * Project: kops
 * File Created: 20-04-2022 13:40:49
 * Author: Clay Risser
 * -----
 * Last Modified: 23-09-2022 11:07:24
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "rancher2_app_v2" "rancher_monitoring" {
  chart_name    = "rancher-monitoring"
  chart_version = "100.1.2+up19.0.3"
  cluster_id    = local.rancher_cluster_id
  name          = "rancher-monitoring"
  namespace     = rancher2_namespace.cattle_monitoring_system.name
  repo_name     = "rancher-charts"
  wait          = true
  values        = <<EOF
grafana:
  sidecar:
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
  thanos:
    enabled: true
    additionalArgs:
      - '--retention.resolution-1h=30d'
      - '--retention.resolution-5m=7d'
      - '--retention.resolution-raw=1d'
    objectConfig:
      type: S3
      config:
        access_key: '${var.aws_access_key_id}'
        bucket: ${aws_s3_bucket.thanos.bucket}
        endpoint: 's3.${var.region}.amazonaws.com'
        insecure: false
        region: '${var.region}'
        secret_key: '${var.aws_secret_access_key}'
        signature_version2: false
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
    kubectl_manifest.loki_datasource,
    kubectl_manifest.tempo_datasource
  ]
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "time_sleep" "rancher_monitoring_ready" {
  depends_on = [
    rancher2_app_v2.rancher_monitoring
  ]
  create_duration = "15s"
}

resource "rancher2_namespace" "cattle_monitoring_system" {
  name       = "cattle-monitoring-system"
  project_id = data.rancher2_project.system.id
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
