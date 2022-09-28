/**
 * File: /main/tempo.tf
 * Project: kops
 * File Created: 23-09-2022 10:17:08
 * Author: Clay Risser
 * -----
 * Last Modified: 28-09-2022 03:15:44
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "tempo" {
  source             = "../modules/helm_release"
  chart_name         = "tempo"
  chart_version      = "0.16.2"

  name               = "tempo"
  repo               = module.grafana_repo.repo
  namespace          = "tempo"
  create_namespace   = true
  rancher_project_id = data.rancher2_project.system.id
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
replicas: 1
tempo:
  retention: 168h
  repository: grafana/tempo
  tag: 1.5.0
  resources:
    requests:
      cpu: 50m
      memory: 50Mi
    limits:
      cpu: 500m
      memory: 500Mi
  storage:
    trace:
      backend: s3
      s3:
        bucket: '${aws_s3_bucket.tempo.bucket}'
        endpoint: 's3.${var.region}.amazonaws.com'
        access_key: '${var.aws_secret_access_key}'
        secret_key: '${var.aws_secret_access_key}'
        insecure: false
  receivers:
    jaeger:
      protocols:
        grpc:
          endpoint: 0.0.0.0:14250
        thrift_binary:
          endpoint: 0.0.0.0:6832
        thrift_compact:
          endpoint: 0.0.0.0:6831
        thrift_http:
          endpoint: 0.0.0.0:14268
    opencensus: {}
    otlp:
      protocols:
        grpc:
          endpoint: "0.0.0.0:4317"
        http:
          endpoint: "0.0.0.0:4318"
EOF
  depends_on         = []
}

resource "kubectl_manifest" "tempo_datasource" {
  yaml_body  = <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: tempo-datasource
  namespace: ${rancher2_namespace.cattle_monitoring_system.name}
  labels:
    grafana_datasource: '1'
data:
  tempo-datasource.yaml: |-
    apiVersion: 1
    datasources:
      - name: Tempo
        type: tempo
        url: http://tempo-gateway.tempo.svc.cluster.local
        access: proxy
        version: 1
EOF
  depends_on = []
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
