# File: /terraform.mk
# Project: kops
# File Created: 15-04-2022 09:14:48
# Author: Clay Risser
# -----
# Last Modified: 29-09-2022 12:20:18
# Modified By: Clay Risser
# -----
# Risser Labs LLC (c) Copyright 2022

export TF_VAR_api_strategy ?= $(API_STRATEGY)
export TF_VAR_autoscaler ?= $(AUTOSCALER)
export TF_VAR_aws_access_key_id ?= $(AWS_ACCESS_KEY_ID)
export TF_VAR_aws_load_balancer_controller ?= $(AWS_LOAD_BALANCER_CONTROLLER)
export TF_VAR_aws_secret_access_key ?= $(AWS_SECRET_ACCESS_KEY)
export TF_VAR_cert_manager ?= $(CERT_MANAGER)
export TF_VAR_cleanup_operator ?= $(CLEANUP_OPERATOR)
export TF_VAR_cloudflare_api_key ?= $(CLOUDFLARE_API_KEY)
export TF_VAR_cloudflare_email ?= $(CLOUDFLARE_EMAIL)
export TF_VAR_cluster_issuer ?= $(CLUSTER_ISSUER)
export TF_VAR_cluster_prefix ?= $(CLUSTER_PREFIX)
export TF_VAR_dns_zone ?= $(DNS_ZONE)
export TF_VAR_external_dns ?= $(EXTERNAL_DNS)
export TF_VAR_flux ?= $(FLUX)
export TF_VAR_flux_git_branch ?= $(FLUX_GIT_BRANCH)
export TF_VAR_flux_git_repository ?= $(FLUX_GIT_REPOSITORY)
export TF_VAR_flux_known_hosts ?= $(FLUX_KNOWN_HOSTS)
export TF_VAR_gitlab_hostname ?= $(GITLAB_HOSTNAME)
export TF_VAR_gitlab_project_id ?= $(GITLAB_PROJECT_ID)
export TF_VAR_gitlab_registry_token ?= $(GITLAB_REGISTRY_TOKEN)
export TF_VAR_gitlab_registry_username ?= $(GITLAB_REGISTRY_USERNAME)
export TF_VAR_goldilocks ?= $(GOLDILOCKS)
export TF_VAR_helm_controller ?= $(HELM_CONTROLLER)
export TF_VAR_helm_operator ?= $(HELM_OPERATOR)
export TF_VAR_ingress_nginx ?= $(INGRESS_NGINX)
export TF_VAR_integration_operator ?= $(INTEGRATION_OPERATOR)
export TF_VAR_iteration ?= $(ITERATION)
export TF_VAR_kanister ?= $(KANISTER)
export TF_VAR_kubed ?= $(KUBED)
export TF_VAR_logging ?= $(LOGGING)
export TF_VAR_olm ?= $(OLM)
export TF_VAR_patch_operator ?= $(PATCH_OPERATOR)
export TF_VAR_public_api_ports ?= $(PUBLIC_API_PORTS)
export TF_VAR_public_nodes_ports ?= $(PUBLIC_NODES_PORTS)
export TF_VAR_rancher ?= $(RANCHER)
export TF_VAR_rancher_admin_password ?= $(RANCHER_ADMIN_PASSWORD)
export TF_VAR_rancher_istio ?= $(RANCHER_ISTIO)
export TF_VAR_rancher_monitoring ?= $(RANCHER_MONITORING)
export TF_VAR_region ?= $(AWS_REGION)
export TF_VAR_s3 ?= $(S3)
export TF_VAR_snapshot_controller ?= $(SNAPSHOT_CONTROLLER)
export TF_VAR_tempo ?= $(TEMPO)
export TF_VAR_velero ?= $(VELERO)

define prevent_destroy
for f in $$($(GIT) ls-files | $(GREP) "\.tf$$"); do \
	$(SED) -i 's|\(prevent_destroy\s\+=\s\+\)\w\+|\1$1|g' $$f; \
done
endef
