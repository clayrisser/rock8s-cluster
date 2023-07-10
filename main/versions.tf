/**
 * File: /main/versions.tf
 * Project: kops
 * File Created: 26-06-2023 07:11:51
 * Author: Clay Risser
 * -----
 * Last Modified: 10-07-2023 15:06:51
 * Modified By: Clay Risser
 * -----
 * BitSpur (c) Copyright 2022
 */

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.6.0"
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
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "3.0.2"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "0.25.3"
    }
    kops = {
      source  = "eddycharly/kops"
      version = "1.25.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }
}
