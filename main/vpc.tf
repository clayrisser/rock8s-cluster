/**
 * File: /vpc.tf
 * Project: main
 * File Created: 14-04-2022 08:10:56
 * Author: Clay Risser
 * -----
 * Last Modified: 21-04-2022 12:09:14
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "vpc" {
  source                               = "terraform-aws-modules/vpc/aws"
  version                              = "~> 3.0"
  name                                 = local.cluster_name
  cidr                                 = "10.0.0.0/16"
  azs                                  = data.aws_availability_zones.available.names
  private_subnets                      = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
  public_subnets                       = ["10.0.240.0/20", "10.0.224.0/20", "10.0.208.0/20"]
  enable_nat_gateway                   = false
  single_nat_gateway                   = false
  one_nat_gateway_per_az               = true
  enable_dns_hostnames                 = true
  enable_flow_log                      = false
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = false
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
  tags = {
    Name = local.cluster_name
  }
}
