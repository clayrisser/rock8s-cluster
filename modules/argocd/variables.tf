variable "enabled" {
  default = true
}

variable "namespace" {
  default = "argocd"
}

variable "chart_version" {
  default = "5.43.4"
}

variable "values" {
  default = ""
}
