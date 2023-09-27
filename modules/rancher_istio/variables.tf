variable "enabled" {
  default = true
}

variable "namespace" {
  default = "istio-system"
}

variable "chart_version" {
  default = "102.2.0+up1.17.2"
}

variable "rancher_cluster_id" {
  type = string
}

variable "rancher_project_id" {
  type = string
}
