module "ingress-nginx" {
  source             = "../modules/ingress_nginx"
  enabled            = var.ingress_nginx
  cluster_entrypoint = local.cluster_entrypoint
  replicas           = 2
  security_group     = aws_security_group.ingress.id
  depends_on = [
    null_resource.wait-for-cluster
  ]
}
