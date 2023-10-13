/**
 * File: /crossplane.tf
 * Project: main
 * File Created: 08-10-2023 17:22:55
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

module "crossplane" {
  source  = "../modules/crossplane"
  enabled = var.crossplane
  depends_on = [
    null_resource.wait-for-cluster
  ]
}

module "crossplane-on-eks" {
  source         = "github.com/clayrisser/crossplane-on-eks//bootstrap/terraform"
  aws_account_id = data.aws_caller_identity.this.account_id
  oidc_provider  = local.oidc_provider
  vpc_id         = module.vpc.vpc_id
  audience       = "amazonaws.com"
  tags           = local.tags
  families = [
    "dynamodb",
    "elasticache",
    "iam",
    "kms",
    "lambda",
    "rds",
    "s3",
    "sns",
    "sqs",
    "vpc"
  ]
  depends_on = [
    module.crossplane
  ]
}

resource "helm_release" "resource-binding-operator" {
  count      = var.crossplane ? 1 : 0
  name       = "resource-binding-operator"
  version    = "0.1.0"
  repository = "https://charts.rock8s.com"
  chart      = "resource-binding-operator"
  namespace  = module.crossplane.namespace
  values = [<<EOF
EOF
  ]
  depends_on = [
    module.crossplane-on-eks
  ]
}

resource "helm_release" "crossplane-on-eks" {
  count      = var.crossplane ? 1 : 0
  name       = "crossplane-on-eks"
  version    = "0.1.0"
  repository = "https://charts.rock8s.com"
  chart      = "crossplane-on-eks"
  namespace  = module.crossplane.namespace
  values = [<<EOF
audience: amazonaws.com
EOF
  ]
  depends_on = [
    module.crossplane-on-eks
  ]
}
