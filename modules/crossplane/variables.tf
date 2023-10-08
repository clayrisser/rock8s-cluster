/**
 * File: /variables.tf
 * Project: crossplane
 * File Created: 08-10-2023 16:31:55
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
  default = "crossplane-system"
}

variable "chart_version" {
  default = "1.13.2"
}

variable "values" {
  default = ""
}

variable "region" {
  default = "us-east-1"
}

variable "access_key" {
  default = ""
}

variable "secret_key" {
  default = ""
}
