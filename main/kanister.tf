/**
 * File: /kanister.tf
 * Project: main
 * File Created: 03-12-2023 03:44:48
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

resource "aws_s3_bucket" "kanister" {
  count         = var.kanister ? 1 : 0
  bucket        = var.kanister_bucket == "" ? "kanister.${local.cluster_name}" : var.kanister_bucket
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "kanister" {
  count  = var.kanister ? 1 : 0
  bucket = aws_s3_bucket.kanister[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_iam_user" "kanister" {
  count = var.kanister ? 1 : 0
  name  = "kanister.${local.cluster_name}"
}

resource "aws_iam_access_key" "kanister" {
  count = var.kanister ? 1 : 0
  user  = aws_iam_user.kanister[0].name
}

resource "aws_iam_user_policy" "kanister" {
  count  = var.kanister ? 1 : 0
  name   = "kanister.${local.cluster_name}"
  user   = aws_iam_user.kanister[0].name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "${aws_s3_bucket.kanister[0].arn}",
        "${aws_s3_bucket.kanister[0].arn}/*"
      ]
    }
  ]
}
EOF
}

module "kanister" {
  source             = "../modules/kanister"
  enabled            = var.kanister
  rancher_cluster_id = local.rancher_cluster_id
  rancher_project_id = local.rancher_project_id
  rock8s_repo        = rancher2_catalog_v2.rock8s[0].name
  access_key         = aws_iam_access_key.kanister[0].id
  bucket             = aws_s3_bucket.kanister[0].bucket
  endpoint           = "s3.${var.region}.amazonaws.com"
  region             = var.region
  secret_key         = aws_iam_access_key.kanister[0].secret
  depends_on = [
    module.kyverno
  ]
}
