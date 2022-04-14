/**
 * File: /main.tf
 * Project: crds
 * File Created: 14-04-2022 07:57:02
 * Author: Clay Risser
 * -----
 * Last Modified: 14-04-2022 08:20:40
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

locals {
  crds      = var.crds
  name      = var.name
  sleep     = var.sleep
  namespace = var.namespace
}

resource "kubernetes_cluster_role" "this" {
  metadata {
    name = "prepare-${local.name}"
    labels = {
      app = "prepare-${local.name}"
    }
  }
  rule {
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
    verbs      = ["create", "get", "patch", "delete"]
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

resource "kubernetes_service_account" "this" {
  metadata {
    name      = "prepare-${local.name}"
    namespace = local.namespace
    labels = {
      app = "prepare-${local.name}"
    }
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

resource "kubernetes_cluster_role_binding" "this" {
  depends_on = [
    kubernetes_service_account.this,
    kubernetes_cluster_role.this
  ]
  metadata {
    name = "prepare-${local.name}"
    labels = {
      app = "prepare-${local.name}"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "prepare-${local.name}"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "prepare-${local.name}"
    namespace = local.namespace
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

resource "kubernetes_job" "this" {
  for_each   = { for crd in local.crds : crd => crd }
  depends_on = [kubernetes_cluster_role_binding.this]
  metadata {
    name      = "prepare-${local.name}"
    namespace = local.namespace
  }
  spec {
    template {
      metadata {}
      spec {
        service_account_name            = "prepare-${local.name}"
        automount_service_account_token = true
        container {
          name  = "kubectl"
          image = "bitnami/kubectl"
          command = [
            "bash",
            "-c",
            join(" ", [
              "kubectl",
              "apply",
              "-f",
              each.value,
              "||",
              "sleep ${local.sleep}"
            ])
          ]
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
  }
  wait_for_completion = true
  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}
