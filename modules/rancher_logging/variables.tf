/**
 * File: /variables.tf
 * Project: rancher_monitoring
 * File Created: 27-09-2023 05:26:35
 * Author: Clay Risser
 * -----
 * BitSpur (c) Copyright 2021 - 2023
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "enabled" {
  default = true
}

variable "namespace" {
  default = "cattle-logging-system"
}

variable "chart_version" {
  default = "102.0.0+up3.17.10"
}

variable "retention_hours" {
  default = "168"
}

variable "region" {
  default = "us-east-1"
}

variable "endpoint" {
  type = string
}

variable "access_key" {
  default = ""
}

variable "secret_key" {
  default = ""
}

variable "grafana_repo" {
  type = string
}

variable "bucket" {
  type = string
}

variable "rancher_cluster_id" {
  type = string
}

variable "rancher_project_id" {
  type = string
}
