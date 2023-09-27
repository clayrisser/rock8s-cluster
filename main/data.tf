data "aws_iam_role" "nodes" {
  name = "nodes.${local.cluster_name}"
  depends_on = [
    kops_cluster_updater.updater
  ]
}

data "aws_iam_role" "masters" {
  name = "masters.${local.cluster_name}"
  depends_on = [
    kops_cluster_updater.updater
  ]
}

data "aws_caller_identity" "this" {}

data "kubernetes_service" "ingress-nginx-controller" {
  count = var.ingress_nginx ? 1 : 0
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  depends_on = [
    module.ingress-nginx
  ]
}

data "aws_route53_zone" "this" {
  name = var.dns_zone
}

data "aws_security_group" "nodes" {
  tags = {
    Name = "nodes.${local.cluster_name}"
  }
  depends_on = [
    kops_cluster_updater.updater
  ]
}
