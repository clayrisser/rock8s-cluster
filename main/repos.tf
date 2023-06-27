/**
 * File: /main/repos.tf
 * Project: kops
 * File Created: 21-04-2022 08:46:03
 * Author: Clay Risser
 * -----
 * Last Modified: 27-06-2023 15:39:42
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

module "rock8s_repo" {
  source             = "../modules/helm_repo"
  url                = "https://charts.rock8s.com"
  name               = "rock8s"
  rancher_cluster_id = local.rancher_cluster_id
}

module "grafana_repo" {
  source             = "../modules/helm_repo"
  name               = "grafana"
  url                = "https://grafana.github.io/helm-charts"
  rancher_cluster_id = local.rancher_cluster_id
}

module "fairwinds_repo" {
  source             = "../modules/helm_repo"
  name               = "fairwinds"
  url                = "https://charts.fairwinds.com/stable"
  rancher_cluster_id = local.rancher_cluster_id
}

module "crypto_outlaws_repo" {
  source             = "../modules/helm_repo"
  url                = "https://crypto-outlaws.gitlab.io/charts"
  name               = "crypto-outlaws"
  rancher_cluster_id = local.rancher_cluster_id
}
