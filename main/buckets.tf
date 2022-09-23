/**
 * File: /main/buckets.tf
 * Project: kops
 * File Created: 18-09-2022 08:43:29
 * Author: Clay Risser
 * -----
 * Last Modified: 23-09-2022 10:30:39
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "aws_s3_bucket" "main" {
  bucket        = var.main_bucket == "" ? local.cluster_name : var.main_bucket
  force_destroy = true
}

resource "aws_s3_bucket" "tempo" {
  bucket        = var.tempo_bucket == "" ? "tempo.${local.cluster_name}" : var.tempo_bucket
  force_destroy = true
}

resource "aws_s3_bucket" "thanos" {
  bucket        = var.thanos_bucket == "" ? "thanos.${local.cluster_name}" : var.thanos_bucket
  force_destroy = true
}

resource "aws_s3_bucket" "loki_chunks" {
  bucket        = var.loki_chunks_bucket == "" ? "chunks.loki.${local.cluster_name}" : var.loki_chunks_bucket
  force_destroy = true
}

resource "aws_s3_bucket" "loki_admin" {
  bucket        = var.loki_admin_bucket == "" ? "admin.loki.${local.cluster_name}" : var.loki_admin_bucket
  force_destroy = true
}

resource "aws_s3_bucket" "loki_ruler" {
  bucket        = var.loki_ruler_bucket == "" ? "ruler.loki.${local.cluster_name}" : var.loki_ruler_bucket
  force_destroy = true
}
