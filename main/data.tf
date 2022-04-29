/**
 * File: /data.tf
 * Project: main
 * File Created: 14-04-2022 08:09:15
 * Author: Clay Risser
 * -----
 * Last Modified: 29-04-2022 17:40:01
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

data "aws_caller_identity" "this" {}

data "aws_availability_zones" "available" {}

data "aws_subnet" "public" {
  count  = length(module.vpc.public_subnets)
  id     = module.vpc.public_subnets[count.index]
  vpc_id = module.vpc.vpc_id
}

data "aws_subnet" "private" {
  count  = length(module.vpc.private_subnets)
  id     = module.vpc.private_subnets[count.index]
  vpc_id = module.vpc.vpc_id
}
