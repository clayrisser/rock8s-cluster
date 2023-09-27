/**
 * File: /vpc.tf
 * Project: main
 * File Created: 27-09-2023 05:26:35
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

module "vpc" {
  source                               = "terraform-aws-modules/vpc/aws"
  version                              = "5.0.0"
  name                                 = local.cluster_name
  cidr                                 = "10.0.0.0/16"
  azs                                  = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets                      = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
  public_subnets                       = ["10.0.240.0/20", "10.0.224.0/20", "10.0.208.0/20"]
  enable_nat_gateway                   = false
  single_nat_gateway                   = false
  one_nat_gateway_per_az               = false
  enable_dns_support                   = true
  enable_dns_hostnames                 = true
  enable_flow_log                      = false
  create_flow_log_cloudwatch_iam_role  = false
  create_flow_log_cloudwatch_log_group = false
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "karpenter.sh/discovery"                      = local.cluster_name
    Type                                          = "private"
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "karpenter.sh/discovery"                      = local.cluster_name
    Type                                          = "public"
  }
  tags = merge(local.tags, {
    Name = local.cluster_name
  })
}

data "aws_subnet" "private" {
  count  = length(module.vpc.private_subnets)
  id     = module.vpc.private_subnets[count.index]
  vpc_id = module.vpc.vpc_id
}

data "aws_subnet" "public" {
  count  = length(module.vpc.public_subnets)
  id     = module.vpc.public_subnets[count.index]
  vpc_id = module.vpc.vpc_id
}
