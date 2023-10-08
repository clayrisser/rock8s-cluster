/**
 * File: /main.tf
 * Project: crossplane
 * File Created: 08-10-2023 16:31:55
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

resource "helm_release" "crossplane" {
  count            = var.enabled ? 1 : 0
  name             = "crossplane"
  version          = var.chart_version
  repository       = "https://charts.crossplane.io/stable"
  chart            = "crossplane"
  namespace        = var.namespace
  create_namespace = true
  values = [<<EOF
EOF
  ]
}

resource "kubectl_manifest" "provider-aws-s3" {
  count     = var.enabled ? 1 : 0
  yaml_body = <<EOF
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws-s3
spec:
  package: xpkg.upbound.io/upbound/provider-aws-s3:v0.37.0
EOF
  depends_on = [
    helm_release.crossplane
  ]
}

resource "kubectl_manifest" "provider-aws-iam" {
  count     = var.enabled ? 1 : 0
  yaml_body = <<EOF
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws-iam
spec:
  package: xpkg.upbound.io/upbound/provider-aws-iam:v0.41.0
EOF
  depends_on = [
    helm_release.crossplane
  ]
}

resource "time_sleep" "provider-aws" {
  create_duration = "60s"
  depends_on = [
    kubectl_manifest.provider-aws-iam,
    kubectl_manifest.provider-aws-s3
  ]
}

resource "kubectl_manifest" "aws-secret" {
  count     = var.enabled ? 1 : 0
  yaml_body = <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: aws-secret
  namespace: ${var.namespace}
type: Opaque
stringData:
  creds: |
    [default]
    aws_access_key_id = ${var.access_key}
    aws_secret_access_key = ${var.secret_key}
EOF
  depends_on = [
    time_sleep.provider-aws
  ]
}

resource "kubectl_manifest" "provider-config" {
  count     = var.enabled ? 1 : 0
  yaml_body = <<EOF
apiVersion: aws.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: ${var.namespace}
      name: aws-secret
      key: creds
EOF
  depends_on = [
    kubectl_manifest.aws-secret
  ]
}
