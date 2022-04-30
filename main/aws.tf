/**
 * File: /aws.tf
 * Project: main
 * File Created: 29-04-2022 14:41:49
 * Author: Clay Risser
 * -----
 * Last Modified: 30-04-2022 12:21:19
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

resource "aws_iam_role" "admin" {
  name = local.cluster_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"
        },
        Condition = {}
      },
    ]
  })
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}

resource "aws_key_pair" "node" {
  key_name   = "nodes.${local.cluster_name}"
  public_key = tls_private_key.node.public_key_openssh
  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }
}
