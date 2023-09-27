variable "enabled" {
  default = true
}

variable "namespace" {
  default = "cattle-monitoring-system"
}

variable "chart_version" {
  default = "102.0.0+up40.1.2"
}

variable "region" {
  default = "us-east-1"
}

variable "retention_hours" {
  default = "168"
}

variable "aws_access_key_id" {
  default = ""
}

variable "aws_secret_access_key" {
  default = ""
}

variable "bucket" {
  default = ""
}

variable "rancher_cluster_id" {
  type = string
}

variable "rancher_project_id" {
  type = string
}
