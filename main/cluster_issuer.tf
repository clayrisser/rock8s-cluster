/**
 * File: /cluster_issuer.tf
 * Project: main
 * File Created: 27-09-2023 07:02:03
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

resource "aws_iam_role" "cluster-issuer" {
  name = "cluster-issuer.${local.cluster_name}"
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
            "${aws_s3_bucket.oidc.bucket}.s3.${var.region}.amazonaws.com:sub" : "system:serviceaccount:cert-manager:cert-manager"
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

resource "aws_iam_role_policy_attachment" "cluster-issuer" {
  role       = aws_iam_role.cluster-issuer.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
  lifecycle {
    prevent_destroy = false
  }
}

module "cluster-issuer" {
  source            = "../modules/cluster_issuer"
  enabled           = var.cluster_issuer
  letsencrypt_email = var.email
  issuers = {
    letsencrypt = true
    selfsigned  = true
    route53 = {
      region  = var.region
      roleArn = aws_iam_role.cluster-issuer.arn
    }
  }
  depends_on = [
    null_resource.wait-for-ingress-nginx
  ]
}
