/**
 * File: /modules/helm_release/versions.tf
 * Project: kops
 * File Created: 14-04-2022 08:04:44
 * Author: Clay Risser
 * -----
 * Last Modified: 27-09-2022 12:43:12
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.6.0"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.24.1"
    }
  }
}
