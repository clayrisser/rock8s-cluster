/**
 * File: /main/logging.tf
 * Project: kops
 * File Created: 18-09-2022 07:59:35
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:09:25
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

module "rancher-logging" {
  source             = "../modules/helm_release"
  enabled            = var.logging
  chart_name         = "rancher-logging"
  chart_version      = "102.0.0+up3.17.10"
  name               = "rancher-logging"
  repo               = "rancher-charts"
  namespace          = "cattle-logging-system"
  rancher_project_id = local.rancher_project_id
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
EOF
  depends_on = [
    null_resource.wait-for-nodes
  ]
}

module "loki" {
  source             = "../modules/helm_release"
  enabled            = var.logging
  chart_name         = "loki"
  chart_version      = "5.6.4"
  name               = "loki"
  repo               = module.grafana-repo.repo
  namespace          = "loki"
  rancher_project_id = local.rancher_project_id
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
gateway:
  basicAuth:
    enabled: false
read:
  replicas: 2
  persistence:
    size: 1Gi
  resources:
    requests:
      cpu: 50m
      memory: 70Mi
    limits:
      cpu: 500m
      memory: 500Mi
write:
  replicas: 2
  persistence:
    size: 1Gi
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
    retention_period: ${tostring(var.retention_hours)}h
  compactor:
    retention_delete_delay: 2h
    retention_delete_worker_count: 150
    retention_enabled: true
  storage:
    type: s3
    s3:
      endpoint: 's3.${var.region}.amazonaws.com'
      region: '${var.region}'
      secretAccessKey: '${var.aws_secret_access_key}'
      accessKeyId: '${var.aws_access_key_id}'
      insecure: false
    bucketNames:
      admin: '${aws_s3_bucket.loki.bucket}'
      chunks: '${aws_s3_bucket.loki.bucket}'
      ruler: '${aws_s3_bucket.loki.bucket}'
EOF
  depends_on = [
    null_resource.wait-for-nodes
  ]
}

resource "kubectl_manifest" "loki-output" {
  count     = (var.logging && local.rancher) ? 1 : 0
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
    module.rancher-logging
  ]
  lifecycle {
    prevent_destroy = false
  }
}

resource "kubectl_manifest" "cluster-flow" {
  count     = (var.logging && local.rancher) ? 1 : 0
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
    module.rancher-logging
  ]
  lifecycle {
    prevent_destroy = false
  }
}

resource "kubectl_manifest" "loki-datasource" {
  count     = (var.logging && local.rancher_monitoring) ? 1 : 0
  yaml_body = <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: loki-datasource
  namespace: ${rancher2_namespace.cattle-monitoring-system[0].name}
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
  depends_on = [
    null_resource.wait-for-nodes
  ]
  lifecycle {
    prevent_destroy = false
  }
}

resource "kubectl_manifest" "logs-dashboard" {
  count     = (var.logging && local.rancher_monitoring) ? 1 : 0
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
    module.rancher-logging,
    time_sleep.rancher-monitoring-ready
  ]
  lifecycle {
    prevent_destroy = false
  }
}
