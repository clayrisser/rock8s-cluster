/**
 * File: /user.tf
 * Project: main
 * File Created: 29-04-2022 14:41:49
 * Author: Clay Risser
 * -----
 * Last Modified: 29-04-2022 16:02:15
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

# resource "aws_iam_group" "this" {
#   name = local.cluster_name
# }

# resource "aws_iam_group_policy_attachment" "ec2" {
#   group      = aws_iam_group.this.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
# }

# resource "aws_iam_group_policy_attachment" "s3" {
#   group      = aws_iam_group.this.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
# }

# resource "aws_iam_group_policy_attachment" "iam" {
#   group      = aws_iam_group.this.name
#   policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
# }

# resource "aws_iam_group_policy_attachment" "vpc" {
#   group      = aws_iam_group.this.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
# }

# resource "aws_iam_group_policy_attachment" "sqs" {
#   group      = aws_iam_group.this.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
# }

# resource "aws_iam_group_policy_attachment" "event_bridge" {
#   group      = aws_iam_group.this.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess"
# }

# resource "aws_iam_user" "this" {
#   name = local.cluster_name
# }

# resource "aws_iam_group_membership" "this" {
#   name  = local.cluster_name
#   users = [aws_iam_user.this.name]
#   group = aws_iam_group.this.name
# }

# resource "aws_iam_access_key" "this" {
#   user = aws_iam_user.this
# }

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
}
