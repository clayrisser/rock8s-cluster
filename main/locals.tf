locals {
  cluster_name         = "${var.cluster_prefix}-${tostring(var.iteration)}.${var.dns_zone}"
  user_name            = "${var.cluster_prefix}.${var.dns_zone}"
  cluster_entrypoint   = local.cluster_name
  kops_kubeconfig_file = "../artifacts/iam_kubeconfig"
  # rancher_cluster_id   = var.rancher ? "local" : ""
  # rancher_project_id   = var.rancher ? data.rancher2_project.system[0].id : ""
  kops_state_store   = "s3://${aws_s3_bucket.main.bucket}/kops"
  public_api_ports   = [for port in split(",", var.public_api_ports) : port]
  public_nodes_ports = [for port in split(",", var.public_nodes_ports) : port]
  ingress_ports      = [for port in split(",", var.ingress_ports) : port]
  cluster_endpoint   = "https://api.${var.cluster_prefix}-${tostring(var.iteration)}.${var.dns_zone}"
  user_exec = {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws-iam-authenticator"
    args = [
      "token",
      "-i",
      local.cluster_name,
      "-r",
      aws_iam_role.admin.arn
    ]
  }
  kubeconfig = jsonencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = "terraform"
      cluster = {
        insecure-skip-tls-verify = true,
        server                   = local.cluster_endpoint
      }
    }]
    users = [{
      name = "terraform"
      user = {
        exec = {
          apiVersion = local.user_exec.api_version
          command    = local.user_exec.command
          args       = local.user_exec.args
        }
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = "terraform"
        user    = "terraform"
      }
    }]
  })
  tags = {
    Cluster = local.cluster_name
  }
  external_dns       = var.external_dns && var.flux
  kanister           = var.kanister && var.flux
  longhorn           = var.longhorn && local.rancher
  rancher            = var.rancher && var.ingress_nginx
  rancher_istio      = var.rancher_istio && local.rancher_monitoring
  rancher_monitoring = var.rancher_monitoring && local.rancher
}
