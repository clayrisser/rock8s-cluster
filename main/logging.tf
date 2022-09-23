/**
 * File: /main/logging.tf
 * Project: kops
 * File Created: 18-09-2022 07:59:35
 * Author: Clay Risser
 * -----
 * Last Modified: 23-09-2022 11:58:08
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "rancher2_app_v2" "rancher_logging" {
  chart_name    = "rancher-logging"
  chart_version = "100.1.3+up3.17.7"
  cluster_id    = local.rancher_cluster_id
  name          = "rancher-logging"
  namespace     = rancher2_namespace.cattle_logging_system.name
  repo_name     = "rancher-charts"
  wait          = true
  values        = <<EOF
EOF
  depends_on    = []
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "rancher2_app_v2" "loki" {
  chart_name    = "loki"
  chart_version = "3.0.7"
  cluster_id    = local.rancher_cluster_id
  name          = "loki"
  namespace     = rancher2_namespace.loki.name
  repo_name     = rancher2_catalog_v2.grafana.name
  wait          = true
  values        = <<EOF
gateway:
  basicAuth:
    enabled: false
read:
  resources:
    requests:
      cpu: 50m
      memory: 70Mi
    limits:
      cpu: 500m
      memory: 500Mi
write:
  resources:
    requests:
      cpu: 50m
      memory: 50Mi
    limits:
      cpu: 500m
      memory: 500Mi
loki:
  auth_enabled: false
  limits_config:
    retention_period: 7d
  compactor:
    retention_delete_delay: 2h
    retention_delete_worker_count: 150
    retention_enabled: true
  table_manager:
    retention_deletes_enabled: true
    retention_period: 7d
  storage:
    type: s3
    s3:
      endpoint: 's3.${var.region}.amazonaws.com'
      region: '${var.region}'
      secretAccessKey: '${var.aws_secret_access_key}'
      accessKeyId: '${var.aws_access_key_id}'
      insecure: false
    bucketNames:
      admin: '${aws_s3_bucket.loki_admin.bucket}'
      chunks: '${aws_s3_bucket.loki_chunks.bucket}'
      ruler: '${aws_s3_bucket.loki_chunks.bucket}'
  config: |
    {{- if .Values.enterprise.enabled}}
    {{- tpl .Values.enterprise.config . }}
    {{- else }}
    auth_enabled: {{ .Values.loki.auth_enabled }}
    {{- end }}
    {{- with .Values.loki.server }}
    server:
      {{- toYaml . | nindent 2}}
    {{- end}}
    memberlist:
      join_members:
        - {{ include "loki.memberlist" . }}
    {{- if .Values.loki.commonConfig}}
    common:
    {{- toYaml .Values.loki.commonConfig | nindent 2}}
      storage:
      {{- include "loki.commonStorageConfig" . | nindent 4}}
    {{- end}}
    {{- with .Values.loki.limits_config }}
    limits_config:
      {{- tpl (. | toYaml) $ | nindent 4 }}
    {{- end }}
    {{- with .Values.loki.memcached.chunk_cache }}
    {{- if and .enabled .host }}
    chunk_store_config:
      chunk_cache_config:
        memcached:
          batch_size: {{ .batch_size }}
          parallelism: {{ .parallelism }}
        memcached_client:
          host: {{ .host }}
          service: {{ .service }}
    {{- end }}
    {{- end }}
    {{- if .Values.loki.schemaConfig}}
    schema_config:
    {{- toYaml .Values.loki.schemaConfig | nindent 2}}
    {{- else }}
    schema_config:
      configs:
        - from: 2022-01-11
          store: boltdb-shipper
          {{- if eq .Values.loki.storage.type "s3" }}
          object_store: s3
          {{- else if eq .Values.loki.storage.type "gcs" }}
          object_store: gcs
          {{- else }}
          object_store: filesystem
          {{- end }}
          schema: v12
          index:
            prefix: loki_index_
            period: 24h
          chunks:
            period: 24h
    {{- end }}
    ruler:
      storage:
      {{- if or .Values.minio.enabled (eq .Values.loki.storage.type "s3") (eq .Values.loki.storage.type "gcs") }}
      {{- include "loki.rulerStorageConfig" . | nindent 4}}
      {{- end }}
    {{- with .Values.loki.rulerConfig}}
    {{- toYaml . | nindent 2}}
    {{- end }}
    {{- with .Values.loki.memcached.results_cache }}
    query_range:
      align_queries_with_step: true
      {{- if and .enabled .host }}
      cache_results: {{ .enabled }}
      results_cache:
        cache:
          default_validity: {{ .default_validity }}
          memcached_client:
            host: {{ .host }}
            service: {{ .service }}
            timeout: {{ .timeout }}
      {{- end }}
    {{- end }}
    {{- with .Values.loki.storage_config }}
    storage_config:
      {{- tpl (. | toYaml) $ | nindent 4 }}
    {{- end }}
    {{- with .Values.loki.query_scheduler }}
    query_scheduler:
      {{- tpl (. | toYaml) $ | nindent 4 }}
    {{- end }}
    {{- with .Values.loki.compactor }}
    compactor:
      {{- tpl (. | toYaml) $ | nindent 4 }}
    {{- end }}
    {{- with .Values.loki.table_manager }}
    table_manager:
      {{- tpl (. | toYaml) $ | nindent 4 }}
    {{- end }}
EOF
  depends_on    = []
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "kubectl_manifest" "loki_output" {
  yaml_body = <<EOF
apiVersion: logging.banzaicloud.io/v1beta1
kind: ClusterOutput
metadata:
  name: loki
  namespace: cattle-logging-system
spec:
  loki:
    url: http://loki-gateway.loki.svc.cluster.local
    configure_kubernetes_labels: true
    buffer:
      timekey: 1m
      timekey_use_utc: true
      timekey_wait: 30s
EOF
  depends_on = [
    rancher2_app_v2.rancher_logging
  ]
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "kubectl_manifest" "cluster_flow" {
  yaml_body = <<EOF
apiVersion: logging.banzaicloud.io/v1beta1
kind: ClusterFlow
metadata:
  name: loki-all
  namespace: cattle-logging-system
spec:
  globalOutputRefs:
    - loki
  match:
    - select: {}
EOF
  depends_on = [
    rancher2_app_v2.rancher_logging
  ]
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "rancher2_namespace" "cattle_logging_system" {
  name       = "cattle-logging-system"
  project_id = data.rancher2_project.system.id
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "rancher2_namespace" "loki" {
  name       = "loki"
  project_id = data.rancher2_project.system.id
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "kubectl_manifest" "loki_datasource" {
  yaml_body  = <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: loki-datasource
  namespace: ${rancher2_namespace.cattle_monitoring_system.name}
  labels:
    grafana_datasource: '1'
data:
  loki-datasource.yaml: |-
    apiVersion: 1
    datasources:
      - name: Loki
        type: loki
        url: http://loki-gateway.loki.svc.cluster.local
        access: proxy
        version: 1
EOF
  depends_on = []
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "kubectl_manifest" "logs_dashboard" {
  yaml_body = <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    grafana_dashboard: '1'
  name: loki-logs-search
  namespace: cattle-dashboards
data:
  loki-logs-search.json: |-
    {
      "annotations": {
        "list": [
          {
            "$$hashKey": "object:75",
            "builtIn": 1,
            "datasource": "-- Grafana --",
            "enable": true,
            "hide": true,
            "iconColor": "rgba(0, 211, 255, 1)",
            "name": "Annotations & Alerts",
            "type": "dashboard"
          }
        ]
      },
      "description": "loki logs panel",
      "editable": true,
      "gnetId": 12019,
      "graphTooltip": 0,
      "id": 39,
      "iteration": 1663601370917,
      "links": [],
      "panels": [
        {
          "aliasColors": {},
          "bars": true,
          "dashLength": 10,
          "dashes": false,
          "datasource": "Loki",
          "fieldConfig": {
            "defaults": {
              "links": []
            },
            "overrides": []
          },
          "fill": 1,
          "fillGradient": 0,
          "gridPos": {
            "h": 3,
            "w": 24,
            "x": 0,
            "y": 0
          },
          "hiddenSeries": false,
          "id": 6,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
            "show": false,
            "total": false,
            "values": false
          },
          "lines": false,
          "linewidth": 1,
          "nullPointMode": "null",
          "options": {
            "alertThreshold": true
          },
          "percentage": false,
          "pluginVersion": "7.5.11",
          "pointradius": 2,
          "points": false,
          "renderer": "flot",
          "seriesOverrides": [],
          "spaceLength": 10,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "sum(count_over_time({namespace=\"$namespace\", instance=~\"$pod\"} |~ \"$search\"[$__interval]))",
              "refId": "A"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeRegions": [],
          "timeShift": null,
          "tooltip": {
            "shared": true,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "buckets": null,
            "mode": "time",
            "name": null,
            "show": true,
            "values": []
          },
          "yaxes": [
            {
              "$$hashKey": "object:168",
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": null,
              "show": false
            },
            {
              "$$hashKey": "object:169",
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": null,
              "show": false
            }
          ],
          "yaxis": {
            "align": false,
            "alignLevel": null
          }
        },
        {
          "datasource": "Loki",
          "fieldConfig": {
            "defaults": {},
            "overrides": []
          },
          "gridPos": {
            "h": 25,
            "w": 24,
            "x": 0,
            "y": 3
          },
          "id": 2,
          "maxDataPoints": "",
          "options": {
            "dedupStrategy": "none",
            "showLabels": false,
            "showTime": true,
            "sortOrder": "Descending",
            "wrapLogMessage": true
          },
          "targets": [
            {
              "expr": "{namespace=\"$namespace\", instance=~\"$pod\"} |~ \"$search\"",
              "refId": "A"
            }
          ],
          "timeFrom": null,
          "timeShift": null,
          "title": "Logs Panel",
          "type": "logs"
        },
        {
          "datasource": null,
          "fieldConfig": {
            "defaults": {},
            "overrides": []
          },
          "gridPos": {
            "h": 3,
            "w": 24,
            "x": 0,
            "y": 28
          },
          "id": 4,
          "options": {
            "content": "<div style=\"text-align:center\"> For Grafana Loki blog example </div>\n\n\n",
            "mode": "html"
          },
          "pluginVersion": "7.5.11",
          "timeFrom": null,
          "timeShift": null,
          "transparent": true,
          "type": "text"
        }
      ],
      "schemaVersion": 27,
      "style": "dark",
      "tags": [],
      "templating": {
        "list": [
          {
            "allValue": null,
            "current": {
              "selected": true,
              "text": "olm",
              "value": "olm"
            },
            "datasource": "Prometheus",
            "definition": "label_values(kube_pod_info, namespace)",
            "description": null,
            "error": null,
            "hide": 0,
            "includeAll": false,
            "label": null,
            "multi": false,
            "name": "namespace",
            "options": [],
            "query": {
              "query": "label_values(kube_pod_info, namespace)",
              "refId": "Prometheus-namespace-Variable-Query"
            },
            "refresh": 1,
            "regex": "",
            "skipUrlSync": false,
            "sort": 0,
            "tagValuesQuery": "",
            "tags": [],
            "tagsQuery": "",
            "type": "query",
            "useTags": false
          },
          {
            "allValue": ".*",
            "current": {
              "selected": true,
              "tags": [],
              "text": [
                "All"
              ],
              "value": [
                "$__all"
              ]
            },
            "datasource": "Prometheus",
            "definition": "label_values(container_network_receive_bytes_total{namespace=~\"$namespace\"},pod)",
            "description": null,
            "error": null,
            "hide": 0,
            "includeAll": true,
            "label": null,
            "multi": true,
            "name": "pod",
            "options": [],
            "query": {
              "query": "label_values(container_network_receive_bytes_total{namespace=~\"$namespace\"},pod)",
              "refId": "Prometheus-pod-Variable-Query"
            },
            "refresh": 1,
            "regex": "",
            "skipUrlSync": false,
            "sort": 0,
            "tagValuesQuery": "",
            "tags": [],
            "tagsQuery": "",
            "type": "query",
            "useTags": false
          },
          {
            "current": {
              "selected": false,
              "text": "",
              "value": ""
            },
            "description": null,
            "error": null,
            "hide": 0,
            "label": null,
            "name": "search",
            "options": [
              {
                "text": "level=warn",
                "value": "level=warn"
              },
              {
                "text": "level=info",
                "value": "level=info"
              },
              {
                "text": "level=error",
                "value": "level=error"
              }
            ],
            "query": "",
            "skipUrlSync": false,
            "type": "textbox"
          }
        ]
      },
      "time": {
        "from": "now-30m",
        "to": "now"
      },
      "timepicker": {
        "refresh_intervals": [
          "5s",
          "10s",
          "30s",
          "1m",
          "5m",
          "15m",
          "30m",
          "1h",
          "2h",
          "1d"
        ]
      },
      "timezone": "",
      "title": "Logs",
      "uid": "aiF7eehie2",
      "version": 1
    }
EOF
  depends_on = [
    rancher2_app_v2.rancher_logging,
    time_sleep.rancher_monitoring_ready
  ]
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
