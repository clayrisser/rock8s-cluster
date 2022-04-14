/**
 * File: /main.tf
 * Project: main
 * File Created: 14-04-2022 08:10:56
 * Author: Clay Risser
 * -----
 * Last Modified: 14-04-2022 08:20:40
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "vpc" {
  source                               = "terraform-aws-modules/vpc/aws"
  version                              = "~> 3.0"
  name                                 = var.cluster_name
  cidr                                 = "10.0.0.0/16"
  azs                                  = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets                      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets                       = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway                   = false
  single_nat_gateway                   = false
  one_nat_gateway_per_az               = true
  enable_dns_hostnames                 = true
  enable_flow_log                      = false
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = false
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  }
  tags = {
    Name = local.cluster_name
  }
}
