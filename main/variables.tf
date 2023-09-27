variable "public_api_ports" {
  default = "22,443"
}

variable "public_nodes_ports" {
  default = "22,80,443"
}

variable "region" {
  default = "us-east-2"
}

variable "cluster_prefix" {
  default = "kops"
}

variable "iteration" {
  default = 0
}

variable "rancher_admin_password" {
  default = "rancherP@ssw0rd"
}

variable "main_bucket" {
  default = ""
}

variable "oidc_bucket" {
  default = ""
}

variable "tempo_bucket" {
  default = ""
}

variable "thanos_bucket" {
  default = ""
}

variable "loki_bucket" {
  default = ""
}

variable "api_strategy" {
  default = "LB"
  validation {
    condition     = contains(["DNS", "LB"], var.api_strategy)
    error_message = "Allowed values for entrypoint_strategy are \"DNS\" or \"LB\"."
  }
}

variable "dns_zone" {
  type = string
}

variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_access_key" {
  type = string
}

variable "letsencrypt_email" {
  type    = string
  default = "email@example.com"
}

variable "rancher" {
  type    = bool
  default = true
}

variable "cleanup_operator" {
  type    = bool
  default = true
}

variable "cluster_issuer" {
  type    = bool
  default = true
}

variable "external_dns" {
  type    = bool
  default = true
}

variable "flux" {
  type    = bool
  default = true
}

variable "argo" {
  type    = bool
  default = true
}

variable "kanister" {
  type    = bool
  default = true
}

variable "kubed" {
  type    = bool
  default = true
}

variable "logging" {
  type    = bool
  default = true
}

variable "ingress_nginx" {
  type    = bool
  default = true
}

variable "olm" {
  type    = bool
  default = true
}

variable "rancher_istio" {
  type    = bool
  default = true
}

variable "rancher_monitoring" {
  type    = bool
  default = true
}

variable "tempo" {
  type    = bool
  default = true
}

variable "efs_csi" {
  type    = bool
  default = true
}

variable "longhorn" {
  type    = bool
  default = false
}

variable "autoscaler" {
  type    = bool
  default = true
}

variable "reloader" {
  type    = bool
  default = true
}

variable "retention_hours" {
  type    = number
  default = 168
}

variable "ack_services" {
  default = "s3,iam,rds"
}

variable "ingress_ports" {
  default = "80,443"
}
