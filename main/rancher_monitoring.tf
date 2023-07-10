/**
 * File: /main/rancher_monitoring.tf
 * Project: kops
 * File Created: 20-04-2022 13:40:49
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:09:34
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

module "rancher-monitoring" {
  source             = "../modules/helm_release"
  enabled            = local.rancher_monitoring
  chart_name         = "rancher-monitoring"
  chart_version      = "102.0.0+up40.1.2"
  name               = "rancher-monitoring"
  repo               = "rancher-charts"
  namespace          = rancher2_namespace.cattle-monitoring-system[0].name
  rancher_project_id = local.rancher_project_id
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
grafana:
  sidecar:
    dashboards:
      searchNamespace: cattle-dashboards
  persistence:
    size: 1Gi
    storageClassName: gp2
    type: pvc
    accessModes:
      - ReadWriteOnce
prometheus:
  prometheusSpec:
    scrapeInterval: 2m
    evaluationInterval: 2m
    retention: ${tostring(var.retention_hours)}h
    retentionSize: 1GiB
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
      - '--retention.resolution-1h=${tostring(var.retention_hours)}h'
      - '--retention.resolution-5m=${tostring(var.retention_hours * 0.6)}h'
      - '--retention.resolution-raw=${tostring(var.retention_hours * 0.2)}h'
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
    kubectl_manifest.loki-datasource,
    kubectl_manifest.tempo-datasource,
    null_resource.wait-for-nodes
  ]
}

resource "time_sleep" "rancher-monitoring-ready" {
  count = local.rancher_monitoring ? 1 : 0
  depends_on = [
    module.rancher-monitoring
  ]
  create_duration = "15s"
}

resource "rancher2_namespace" "cattle-monitoring-system" {
  count      = local.rancher_monitoring ? 1 : 0
  name       = "cattle-monitoring-system"
  project_id = local.rancher_project_id
  lifecycle {
    prevent_destroy = false
  }
}
