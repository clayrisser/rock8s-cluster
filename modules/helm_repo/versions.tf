/**
 * File: /modules/helm_repo/versions.tf
 * Project: kops
 * File Created: 14-04-2022 08:04:44
 * Author: Clay Risser
 * -----
 * Last Modified: 27-09-2022 13:29:49
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.24.1"
    }
  }
}
