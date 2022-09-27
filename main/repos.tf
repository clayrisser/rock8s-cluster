/**
 * File: /main/repos.tf
 * Project: kops
 * File Created: 21-04-2022 08:46:03
 * Author: Clay Risser
 * -----
 * Last Modified: 27-09-2022 13:34:48
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "risserlabs_repo" {
  source             = "../modules/helm_repo"
  url                = "https://risserlabs.gitlab.io/community/charts"
  name               = "risserlabs"
  rancher_cluster_id = local.rancher_cluster_id
}

module "fluxcd_repo" {
  source             = "../modules/helm_repo"
  name               = "fluxcd"
  url                = "https://charts.fluxcd.io"
  rancher_cluster_id = local.rancher_cluster_id
}

module "grafana_repo" {
  source             = "../modules/helm_repo"
  name               = "grafana"
  url                = "https://grafana.github.io/helm-charts"
  rancher_cluster_id = local.rancher_cluster_id
}
