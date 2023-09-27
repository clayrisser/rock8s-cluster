variable "enabled" {
  default = true
}

variable "namespace" {
  default = "cert-manager"
}

variable "issuers" {
  default = {
    route53_prod     = null
    letsencrypt_prod = true
  }
}

variable "letsencrypt_email" {
  type = string
}
