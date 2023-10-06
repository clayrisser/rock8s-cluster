/**
 * File: /buckets.tf
 * Project: main
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
  tags = {
    Cluster = local.cluster_name
  }
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
  count         = local.tempo ? 1 : 0
  bucket        = var.tempo_bucket == "" ? replace("tempo-${local.cluster_name}", ".", "-") : var.tempo_bucket
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tempo" {
  count  = local.tempo ? 1 : 0
  bucket = aws_s3_bucket.tempo[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tempo" {
  count  = local.tempo ? 1 : 0
  bucket = aws_s3_bucket.tempo[0].id
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

# resource "aws_s3_bucket" "thanos" {
#   bucket        = var.thanos_bucket == "" ? replace("thanos-${local.cluster_name}", ".", "-") : var.thanos_bucket
#   force_destroy = true
#   lifecycle {
#     prevent_destroy = false
#   }
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "thanos" {
#   bucket = aws_s3_bucket.thanos.id
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# resource "aws_s3_bucket_lifecycle_configuration" "thanos" {
#   bucket = aws_s3_bucket.thanos.id
#   rule {
#     id     = "retention"
#     status = "Enabled"
#     expiration {
#       days = ceil(var.retention_hours / 24)
#     }
#   }
#   lifecycle {
#     prevent_destroy = false
#   }
# }

resource "aws_s3_bucket" "loki" {
  count         = local.rancher_logging ? 1 : 0
  bucket        = var.loki_bucket == "" ? replace("loki-${local.cluster_name}", ".", "-") : var.loki_bucket
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "loki" {
  count  = local.rancher_logging ? 1 : 0
  bucket = aws_s3_bucket.loki[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "loki" {
  count  = local.rancher_logging ? 1 : 0
  bucket = aws_s3_bucket.loki[0].id
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
