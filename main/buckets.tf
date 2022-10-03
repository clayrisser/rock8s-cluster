/**
 * File: /main/buckets.tf
 * Project: kops
 * File Created: 18-09-2022 08:43:29
 * Author: Clay Risser
 * -----
 * Last Modified: 03-10-2022 13:47:52
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "aws_s3_bucket" "main" {
  bucket        = var.main_bucket == "" ? local.cluster_name : var.main_bucket
  force_destroy = true
}

resource "aws_s3_bucket" "tempo" {
  bucket        = var.tempo_bucket == "" ? "tempo.${local.cluster_name}" : var.tempo_bucket
  force_destroy = true
  lifecycle_rule {
    id      = "retention"
    prefix  = "single-tenant/"
    enabled = true
    expiration {
      days = ceil(var.retention_hours / 24)
    }
  }
}

resource "aws_s3_bucket" "thanos" {
  bucket        = var.thanos_bucket == "" ? "thanos.${local.cluster_name}" : var.thanos_bucket
  force_destroy = true
  lifecycle_rule {
    id      = "retention"
    enabled = true
    expiration {
      days = ceil(var.retention_hours / 24)
    }
  }
}

resource "aws_s3_bucket" "loki" {
  bucket        = var.loki_bucket == "" ? "loki.${local.cluster_name}" : var.loki_bucket
  force_destroy = true
  lifecycle_rule {
    id      = "retention"
    enabled = true
    expiration {
      days = ceil(var.retention_hours / 24)
    }
  }
}
