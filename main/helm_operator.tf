/**
 * File: /main/helm_operator.tf
 * Project: kops
 * File Created: 07-05-2022 03:17:43
 * Author: Clay Risser
 * -----
 * Last Modified: 27-09-2022 13:36:33
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "helm_operator" {
  source             = "../modules/helm_release"
  chart_name         = "helm-operator"
  chart_version      = "1.2.0"
  name               = "helm-operator"
  repo               = module.fluxcd_repo.repo
  namespace          = "flux"
  create_namespace   = true
  rancher_project_id = data.rancher2_project.system.id
  rancher_cluster_id = local.rancher_cluster_id
  values             = <<EOF
helm:
  versions: v3
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/arch
              operator: In
              values:
                - amd64
resources:
  limits:
    cpu: 50m
    memory: 1Gi
  requests:
    cpu: 40m
    memory: 64Mi
EOF
}
