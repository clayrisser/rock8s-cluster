/**
 * File: /versions.tf
 * Project: main
 * File Created: 27-09-2023 05:26:34
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

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.21.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "3.2.0"
    }
    kops = {
      source  = "clayrisser/kops"
      version = "1.28.0"
      # source  = "eddycharly/kops"
      # version = "1.25.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
    kustomization = {
      source  = "kbst/kustomization"
      version = "0.9.4"
    }
    argocd = {
      source  = "oboukili/argocd"
      version = "6.0.3"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "16.4.1"
    }
  }
}
