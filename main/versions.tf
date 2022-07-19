/**
 * File: /versions.tf
 * Project: main
 * File Created: 14-04-2022 08:04:44
 * Author: Clay Risser
 * -----
 * Last Modified: 19-07-2022 15:04:21
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.72"
    }
    helm = {
      source = "hashicorp/helm"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    local = {
      source = "hashicorp/local"
    }
    null = {
      source = "hashicorp/null"
    }
    random = {
      source = "hashicorp/random"
    }
    template = {
      source = "hashicorp/template"
    }
    time = {
      source = "hashicorp/time"
    }
    rancher2 = {
      source = "rancher/rancher2"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "0.11.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "3.7.0"
    }
    kops = {
      source  = "eddycharly/kops"
      version = ">= 1.23.5"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.3.0"
    }
  }
}
