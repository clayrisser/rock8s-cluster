/**
 * File: /modules/helm_release/main.tf
 * Project: kops
 * File Created: 27-09-2022 10:24:31
 * Author: Clay Risser
 * -----
 * Last Modified: 27-06-2023 15:39:42
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

locals {
  is_rancher       = var.rancher_cluster_id != ""
  requires_rancher = var.repo == "rancher-charts"
}

resource "helm_release" "ingress_nginx" {
  count            = (var.enabled && !local.is_rancher && !local.requires_rancher) ? 1 : 0
  version          = var.chart_version
  name             = var.name
  repository       = var.repo
  chart            = var.chart_name
  namespace        = var.namespace
  create_namespace = var.create_namespace
  values           = [var.values]
  lifecycle {
    prevent_destroy = false
  }
}

resource "rancher2_app_v2" "this" {
  count         = (var.enabled && local.is_rancher) ? 1 : 0
  chart_name    = var.chart_name
  chart_version = var.chart_version
  cluster_id    = var.rancher_cluster_id
  name          = var.name
  namespace     = local.is_rancher && var.create_namespace ? rancher2_namespace.this[0].name : var.namespace
  repo_name     = var.repo
  wait          = true
  values        = var.values
  lifecycle {
    prevent_destroy = false
  }
}

resource "rancher2_namespace" "this" {
  count      = (var.enabled && local.is_rancher && var.create_namespace) ? 1 : 0
  name       = var.namespace
  project_id = var.rancher_project_id
  lifecycle {
    prevent_destroy = false
  }
}
