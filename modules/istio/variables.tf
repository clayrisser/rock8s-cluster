variable "enabled" {
  default = true
}

variable "namespace" {
  default = "istio-system"
}

variable "chart_version" {
  default = "1.19.0"
}

variable "values" {
  default = ""
}
