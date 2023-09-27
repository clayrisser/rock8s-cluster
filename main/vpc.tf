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
