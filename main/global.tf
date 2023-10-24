/**
 * File: /global.tf
 * Project: main
 * File Created: 16-10-2023 15:51:39
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

resource "kubectl_manifest" "global-namespace" {
  yaml_body = <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: global
EOF
  depends_on = [
    null_resource.wait-for-cluster
  ]
}

resource "kubectl_manifest" "cluster-environment" {
  yaml_body = <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-environment
  namespace: global
data:
  awsAccountId: '${data.aws_caller_identity.this.account_id}'
  awsRegion: '${var.region}'
  clusterName: '${local.cluster_name}'
  oidcProvider: '${local.oidc_provider}'
  vpcId: '${module.vpc.vpc_id}'
EOF
  depends_on = [
    kubectl_manifest.global-namespace
  ]
}

resource "kubectl_manifest" "sync-cluster-environment" {
  count     = var.kyverno ? 1 : 0
  yaml_body = <<EOF
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: sync-cluster-environment
spec:
  background: true
  validationFailureAction: enforce
  rules:
    - name: config-map
      match:
        resources:
          kinds:
            - Namespace
      exclude:
        resources:
          namespaces:
            - global
      generate:
        synchronize: true
        apiVersion: v1
        kind: ConfigMap
        name: cluster-environment
        namespace: "{{request.object.metadata.name}}"
        clone:
          namespace: global
          name: cluster-environment
EOF
  depends_on = [
    module.kyverno,
    kubectl_manifest.cluster-environment
  ]
}
