# File: /terraform.mk
# Project: eks
# File Created: 15-04-2022 09:14:48
# Author: Clay Risser
# -----
# Last Modified: 15-04-2022 09:15:33
# Modified By: Clay Risser
# -----
# Risser Labs LLC (c) Copyright 2022

export TF_VAR_region ?= $(AWS_REGION)
export TF_VAR_cluster_name ?= $(EKS_CLUSTER)
