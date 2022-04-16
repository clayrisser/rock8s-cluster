/**
 * File: /main.tf
 * Project: gitlab
 * File Created: 16-04-2022 01:29:38
 * Author: Clay Risser
 * -----
 * Last Modified: 16-04-2022 01:32:07
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

terraform {
  required_version = ">= 0.12.26"
  required_providers {
    gitlab = {
      source = "gitlabhq/gitlab"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "gitlab_deploy_key" "ssh" {
  project = var.gitlab_project
  title   = var.name
  key     = tls_private_key.ssh.public_key_openssh
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
