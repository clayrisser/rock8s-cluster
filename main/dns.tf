/**
 * File: /dns.tf
 * Project: main
 * File Created: 16-04-2022 03:29:18
 * Author: Clay Risser
 * -----
 * Last Modified: 19-04-2022 09:33:17
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

module "cluster" {
  source = "../modules/dns/cloudflare"
  # source      = "../modules/dns/route53"
  name        = local.cluster_name
  domain      = var.domain
  record      = data.kubernetes_service.ingress_nginx_controller.status.0.load_balancer.0.ingress.0.hostname
  record_type = "CNAME"
  create_zone = false
  # region      = var.region
  providers = {
    # aws        = aws
    cloudflare = cloudflare
  }
}
