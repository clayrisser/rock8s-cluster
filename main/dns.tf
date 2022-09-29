/**
 * File: /main/dns.tf
 * Project: kops
 * File Created: 30-04-2022 16:46:19
 * Author: Clay Risser
 * -----
 * Last Modified: 29-09-2022 14:14:12
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "aws_route53_record" "cluster" {
  count   = var.ingress_nginx ? 1 : 0
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.cluster_entrypoint
  type    = "CNAME"
  ttl     = "300"
  records = [data.kubernetes_service.ingress_nginx_controller[0].status[0].load_balancer[0].ingress[0].hostname]
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
