output "hostname" {
  value = data.kubernetes_service.ingress-nginx[0].status[0].load_balancer[0].ingress[0].hostname
}
