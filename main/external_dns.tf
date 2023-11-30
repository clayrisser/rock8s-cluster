/**
 * File: /external_dns.tf
 * Project: main
 * File Created: 27-09-2023 05:26:34
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

resource "aws_iam_role" "external-dns" {
  name = "external-dns.${local.cluster_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:oidc-provider/${aws_s3_bucket.oidc.bucket}.s3.${var.region}.amazonaws.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${aws_s3_bucket.oidc.bucket}.s3.${var.region}.amazonaws.com:sub" : "system:serviceaccount:external-dns:external-dns-release"
          }
        }
      }
    ]
  })
  tags = {
    Cluster = local.cluster_name
  }
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_iam_role_policy_attachment" "external-dns" {
  role       = aws_iam_role.external-dns.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
  lifecycle {
    prevent_destroy = false
  }
}

module "external-dns" {
  source  = "../modules/external_dns"
  enabled = var.external_dns
  dns_providers = {
    route53 = {
      region  = var.region
      roleArn = aws_iam_role.external-dns.arn
    }
  }
  depends_on = [
    null_resource.wait-for-cluster
  ]
}
