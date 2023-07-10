/**
 * File: /main/iam.tf
 * Project: kops
 * File Created: 28-06-2023 14:10:15
 * Author: Clay Risser
 * -----
 * Last Modified: 01-07-2023 09:32:58
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022 - 2023
 */

locals {
  elevated_namespaces = []
  elevated_policies = [
    "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
  ]
  external_policies = [
    "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
  ]
}
