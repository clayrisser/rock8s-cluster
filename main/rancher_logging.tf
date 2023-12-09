/**
 * File: /rancher_logging.tf
 * Project: main
 * File Created: 05-10-2023 09:25:30
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

resource "aws_iam_user" "loki" {
  count = local.rancher_logging ? 1 : 0
  name  = "loki.${local.cluster_name}"
}

resource "aws_iam_access_key" "loki" {
  count = local.rancher_logging ? 1 : 0
  user  = aws_iam_user.loki[0].name
}

resource "aws_iam_user_policy" "loki" {
  count  = local.rancher_logging ? 1 : 0
  name   = "loki.${local.cluster_name}"
  user   = aws_iam_user.loki[0].name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "${aws_s3_bucket.loki[0].arn}",
        "${aws_s3_bucket.loki[0].arn}/*"
      ]
    }
  ]
}
EOF
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

module "rancher-logging" {
  source             = "../modules/rancher_logging"
  enabled            = local.rancher_logging
  rancher_cluster_id = local.rancher_cluster_id
  rancher_project_id = local.rancher_project_id
  bucket             = aws_s3_bucket.loki[0].bucket
  endpoint           = "s3.${var.region}.amazonaws.com"
  region             = var.region
  access_key         = aws_iam_access_key.loki[0].id
  secret_key         = aws_iam_access_key.loki[0].secret
  grafana_repo       = rancher2_catalog_v2.grafana[0].name
  retention          = "720h"
  depends_on = [
    rancher2_namespace.rancher-monitoring
  ]
}
