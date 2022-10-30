/**
 * File: /main/buckets.tf
 * Project: kops
 * File Created: 18-09-2022 08:43:29
 * Author: Clay Risser
 * -----
 * Last Modified: 30-10-2022 08:17:18
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "aws_s3_bucket" "main" {
  bucket        = var.main_bucket == "" ? local.cluster_name : var.main_bucket
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket" "oidc" {
  bucket        = var.oidc_bucket == "" ? "oidc.${local.cluster_name}" : var.main_bucket
  acl           = "public-read"
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket" "tempo" {
  bucket        = var.tempo_bucket == "" ? "tempo.${local.cluster_name}" : var.tempo_bucket
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tempo" {
  bucket = aws_s3_bucket.tempo.id
  rule {
    id     = "retention"
    status = "Enabled"
    filter {
      prefix = "single-tenant/"
    }
    expiration {
      days = ceil(var.retention_hours / 24)
    }
  }
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket" "thanos" {
  bucket        = var.thanos_bucket == "" ? "thanos.${local.cluster_name}" : var.thanos_bucket
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "thanos" {
  bucket = aws_s3_bucket.thanos.id
  rule {
    id     = "retention"
    status = "Enabled"
    expiration {
      days = ceil(var.retention_hours / 24)
    }
  }
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket" "loki" {
  bucket        = var.loki_bucket == "" ? "loki.${local.cluster_name}" : var.loki_bucket
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "loki" {
  bucket = aws_s3_bucket.loki.id
  rule {
    id     = "retention"
    status = "Enabled"
    expiration {
      days = ceil(var.retention_hours / 24)
    }
  }
  lifecycle {
    prevent_destroy = false
  }
}
