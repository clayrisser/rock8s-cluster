/**
 * File: /main/buckets.tf
 * Project: kops
 * File Created: 18-09-2022 08:43:29
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:04:46
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

resource "aws_s3_bucket" "main" {
  bucket        = var.main_bucket == "" ? replace(local.cluster_name, ".", "-") : var.main_bucket
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket" "oidc" {
  bucket        = var.oidc_bucket == "" ? replace("oidc-${local.cluster_name}", ".", "-") : var.main_bucket
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_ownership_controls" "oidc" {
  bucket = aws_s3_bucket.oidc.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_public_access_block" "oidc" {
  bucket                  = aws_s3_bucket.oidc.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_acl" "oidc" {
  bucket = aws_s3_bucket.oidc.id
  acl    = "public-read"
  depends_on = [
    aws_s3_bucket_ownership_controls.oidc,
    aws_s3_bucket_public_access_block.oidc,
  ]
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket" "tempo" {
  bucket        = var.tempo_bucket == "" ? replace("tempo-${local.cluster_name}", ".", "-") : var.tempo_bucket
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tempo" {
  bucket = aws_s3_bucket.tempo.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
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
  bucket        = var.thanos_bucket == "" ? replace("thanos-${local.cluster_name}", ".", "-") : var.thanos_bucket
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "thanos" {
  bucket = aws_s3_bucket.thanos.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
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
  bucket        = var.loki_bucket == "" ? replace("loki-${local.cluster_name}", ".", "-") : var.loki_bucket
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "loki" {
  bucket = aws_s3_bucket.loki.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
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
