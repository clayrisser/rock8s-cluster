# File: /terraform.mk
# Project: eks
# File Created: 15-04-2022 09:14:48
# Author: Clay Risser
# -----
# Last Modified: 17-04-2022 05:05:38
# Modified By: Clay Risser
# -----
# Risser Labs LLC (c) Copyright 2022

export TF_VAR_cloudflare_api_key ?= $(CLOUDFLARE_API_KEY)
export TF_VAR_cloudflare_email ?= $(CLOUDFLARE_EMAIL)
export TF_VAR_cluster_name ?= $(EKS_CLUSTER)
export TF_VAR_domain ?= $(DOMAIN)
export TF_VAR_flux_git_branch ?= $(FLUX_GIT_BRANCH)
export TF_VAR_flux_git_repository ?= $(FLUX_GIT_REPOSITORY)
export TF_VAR_flux_known_hosts ?= $(FLUX_KNOWN_HOSTS)
export TF_VAR_gitlab_hostname ?= $(GITLAB_HOSTNAME)
export TF_VAR_gitlab_registry_token ?= $(GITLAB_REGISTRY_TOKEN)
export TF_VAR_gitlab_registry_username ?= $(GITLAB_REGISTRY_USERNAME)
export TF_VAR_gitlab_token ?= $(GITLAB_TOKEN)
export TF_VAR_iteration ?= $(ITERATION)
export TF_VAR_rancher_admin_password ?= $(RANCHER_ADMIN_PASSWORD)
export TF_VAR_region ?= $(AWS_REGION)
