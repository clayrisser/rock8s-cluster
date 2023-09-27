data "aws_route53_zone" "this" {
  count = (var.issuers.route53_prod != null && var.enabled) ? 1 : 0
  name  = (var.issuers.route53_prod != null && var.enabled) ? var.issuers.route53_prod.zone : null
}

resource "kubectl_manifest" "route53-prod" {
  count = (var.issuers.route53_prod != null && var.enabled) ? 1 : 0
  yaml_body = <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: route53-prod
spec:
  acme:
    server: "https://acme-v02.api.letsencrypt.org/directory"
    email: ${var.letsencrypt_email}
    privateKeySecretRef:
      name: route53-prod-account-key
    solvers:
      - selector:
          dnsZones:
          - '${(var.issuers.route53_prod != null && var.enabled) ?
  data.aws_route53_zone.this[0].name : ""}'
        dns01:
          route53:
            hostedZoneID: '${(var.issuers.route53_prod != null && var.enabled) ?
  data.aws_route53_zone.this[0].zone_id : ""}'
            region: ${(var.issuers.route53_prod != null && var.enabled) ?
(var.issuers.route53_prod.region != null ? var.issuers.route53_prod.region : "us-east-1") : ""}
EOF
}
