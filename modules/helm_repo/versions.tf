/**
 * File: /modules/helm_repo/versions.tf
 * Project: kops
 * File Created: 14-04-2022 08:04:44
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:08:16
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "3.0.2"
    }
  }
}
