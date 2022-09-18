/**
 * File: /main/buckets.tf
 * Project: kops
 * File Created: 18-09-2022 08:43:29
 * Author: Clay Risser
 * -----
 * Last Modified: 18-09-2022 08:56:37
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "aws_s3_bucket" "main_bucket" {
  bucket        = var.main_bucket == "" ? local.cluster_name : var.main_bucket
  force_destroy = true
}

resource "aws_s3_bucket" "loki_chunks_bucket" {
  bucket        = var.loki_chunks_bucket == "" ? "chunks.loki.${local.cluster_name}" : var.loki_chunks_bucket
  force_destroy = true
}

resource "aws_s3_bucket" "loki_admin_bucket" {
  bucket        = var.loki_admin_bucket == "" ? "admin.loki.${local.cluster_name}" : var.loki_admin_bucket
  force_destroy = true
}

resource "aws_s3_bucket" "loki_ruler_bucket" {
  bucket        = var.loki_ruler_bucket == "" ? "ruler.loki.${local.cluster_name}" : var.loki_ruler_bucket
  force_destroy = true
}
