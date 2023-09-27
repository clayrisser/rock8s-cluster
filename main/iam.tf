locals {
  elevated_namespaces = []
  elevated_policies = [
    "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
    "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
  ]
  external_policies = [
    "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
    "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
  ]
}
