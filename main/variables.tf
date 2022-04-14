/**
 * File: /variables.tf
 * Project: main
 * File Created: 14-04-2022 08:12:06
 * Author: Clay Risser
 * -----
 * Last Modified: 14-04-2022 13:19:04
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

variable "region" {
  default = "us-east-2"
}

variable "cluster_name" {
  default = "eks-main"
}

variable "cluster_version" {
  default = "1.21"
}
