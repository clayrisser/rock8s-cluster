resource "aws_route53_record" "cluster" {
  count   = var.ingress_nginx ? 1 : 0
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.cluster_entrypoint
  type    = "CNAME"
  ttl     = "300"
  records = [data.kubernetes_service.ingress-nginx-controller[0].status[0].load_balancer[0].ingress[0].hostname]
  lifecycle {
    prevent_destroy = false
  }
}
