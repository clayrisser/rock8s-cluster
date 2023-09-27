resource "rancher2_namespace" "this" {
  count      = var.enabled ? 1 : 0
  name       = var.namespace
  project_id = var.rancher_project_id
}

# https://blog.csdn.net/u010533742/article/details/124944538

resource "rancher2_app_v2" "this" {
  count         = var.enabled ? 1 : 0
  chart_name    = "rancher-monitoring"
  chart_version = var.chart_version
  cluster_id    = var.rancher_cluster_id
  name          = "rancher-monitoring"
  namespace     = rancher2_namespace.this[0].name
  repo_name     = "rancher-charts"
  wait          = true
  values        = <<EOF
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
    retention: ${var.retention_hours}h
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
  thanosService:
    enabled: true
  extraSecret:
    name: bucket-config
    data:
      objstore.yml: |
        type: S3
        config:
          bucket:
          endpoint:
          access_key:
          secret_key:
          insecure: true
  prometheusSpec:
    disableCompaction: true
    thanos:
      objectStorageConfig:
        name: bucket-config
        key: objstore.yml
  # thanos:
  #   enabled: ${var.bucket != "" ? "true" : "false"}
  #   additionalArgs:
  #     - '--retention.resolution-1h=${tostring(var.retention_hours)}h'
  #     - '--retention.resolution-5m=${tostring(var.retention_hours * 0.6)}h'
  #     - '--retention.resolution-raw=${tostring(var.retention_hours * 0.2)}h'
  #   objectConfig:
  #     type: S3
  #     config:
  #       access_key: '${var.aws_access_key_id}'
  #       bucket: ${var.bucket}
  #       endpoint: 's3.${var.region}.amazonaws.com'
  #       insecure: false
  #       region: '${var.region}'
  #       secret_key: '${var.aws_secret_access_key}'
  #       signature_version2: false
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
prometheus-node-exporter:
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
}

resource "time_sleep" "this" {
  count           = var.enabled ? 1 : 0
  create_duration = "15s"
  depends_on = [
    rancher2_app_v2.this
  ]
}
