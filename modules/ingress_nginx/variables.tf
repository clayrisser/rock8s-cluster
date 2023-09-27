variable "enabled" {
  default = true
}

variable "namespace" {
  default = "ingress-nginx"
}

variable "chart_version" {
  default = "4.7.0"
}

variable "ingress_ports" {
  default = ["80", "443"]
}

variable "values" {
  default = ""
}

variable "replicas" {
  default = 0
}

variable "security_group" {
  default = ""
}

variable "cluster_entrypoint" {
  type = string
}
