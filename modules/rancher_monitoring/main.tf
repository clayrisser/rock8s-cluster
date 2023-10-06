/**
 * File: /main.tf
 * Project: rancher_monitoring
 * File Created: 27-09-2023 05:26:35
 * Author: Clay Risser
 * -----
 * BitSpur (c) Copyright 2021 - 2023
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

 locals {
   namespace = (var.enabled && var.create_namespace) ? rancher2_namespace.this[0].name : var.namespace
 }

resource "rancher2_namespace" "this" {
  count      = (var.enabled && var.create_namespace  ) ? 1 : 0
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
  namespace     = local.namespace
  repo_name     = "rancher-charts"
  wait          = true
  values        = <<EOF
grafana:
  sidecar:
    dashboards:
      searchNamespace: ALL
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
    disableCompaction: ${var.bucket != "" ? "true" : ""}
    ${var.bucket != "" ? "thanos: \"{\"objectStorageConfig\":{\"name\":\"bucket-config\",\"key\":\"objstore.yml\"}}\"" : ""}
  serviceAccount:
    create: true
  thanosService:
    enabled: ${var.bucket != "" ? "true" : "false"}
  extraSecret:
    name: bucket-config
    data:
      objstore.yml: |
        type: S3
        config:
          bucket: ${var.bucket}
          endpoint: ${var.endpoint}
          access_key: ${var.access_key}
          secret_key: ${var.secret_key}
          aws_sdk_auth: ${(var.bucket != "" && (var.access_key == "" || var.secret_key == "")) ? "true" : ""}
          insecure: false
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
