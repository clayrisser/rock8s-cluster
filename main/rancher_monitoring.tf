/**
 * File: /rancher_monitoring.tf
 * Project: main
 * File Created: 03-10-2023 20:41:41
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

resource "aws_s3_bucket" "thanos" {
  count         = local.thanos ? 1 : 0
  bucket        = var.thanos_bucket == "" ? replace("thanos-${local.cluster_name}", ".", "-") : var.thanos_bucket
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "thanos" {
  count  = local.thanos ? 1 : 0
  bucket = aws_s3_bucket.thanos[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "thanos" {
  count  = local.thanos ? 1 : 0
  bucket = aws_s3_bucket.thanos[0].id
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

resource "rancher2_namespace" "rancher-monitoring" {
  count      = local.rancher_monitoring ? 1 : 0
  name       = "cattle-monitoring-system"
  project_id = local.rancher_project_id
}

module "rancher-monitoring" {
  source                  = "../modules/rancher_monitoring"
  enabled                 = local.rancher_monitoring
  create_namespace        = false
  namespace               = local.rancher_monitoring ? rancher2_namespace.rancher-monitoring[0].name : ""
  rancher_cluster_id      = local.rancher_cluster_id
  rancher_project_id      = local.rancher_project_id
  bucket                  = try(aws_s3_bucket.thanos[0].bucket, "")
  endpoint                = "s3.${var.region}.amazonaws.com"
  access_key              = var.aws_access_key_id
  secret_key              = var.aws_secret_access_key
  retention               = "168h"  # 7 days
  retention_resolution_1h = "720h"  # 30 days
  retention_resolution_5m = "8766h" # 1 year
  retention_size          = "1GiB"
  thanos                  = local.thanos
  depends_on = [
    module.rancher,
    module.rancher-logging,
    module.tempo
  ]
}
