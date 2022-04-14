# File: /Makefile
# Project: eks
# File Created: 27-01-2022 11:41:37
# Author: Clay Risser
# -----
# Last Modified: 14-04-2022 13:45:38
# Modified By: Clay Risser
# -----
# Risser Labs LLC (c) Copyright 2022

include mkpm.mk
ifneq (,$(MKPM_READY))
include $(MKPM)/gnu
include $(MKPM)/mkchain
include $(MKPM)/dotenv

export AWS ?= aws
export CLOC ?= cloc
export TERRAFORM ?= terraform
export SSH_KEYGEN ?= ssh-keygen
export KUBECTX ?= $(call ternary,kubectx -h,kubectx,$(call ternary,kubectl ctx -h,kubectl ctx,true))
export KUBECTL ?= $(call ternary,kubectl -h,kubectl,true)
export BASE64 ?= openssl base64
export CURL ?= curl
export SSH ?= ssh

export TF_VAR_region ?= $(AWS_REGION)
export TF_VAR_cluster_name ?= $(EKS_CLUSTER)
export TF_STATE_NAME ?= main
export TF_ROOT ?= main

ifneq (,$(CI))
	TERRAFORM_INPUT_FLAG := -input=false
	TERRAFORM_AUTO_APPROVE_FLAG := -auto-approve
endif

ACTIONS += init ## initializes terraform
$(ACTION)/init: $(TF_ROOT)/versions.tf $(TF_ROOT)/backend.tf
	@$(CD) $(TF_ROOT) && $(TERRAFORM) init $(TERRAFORM_INPUT_FLAG) -reconfigure \
		-backend-config="address=https://$(GITLAB_HOSTNAME)/api/v4/projects/$(PROJECT_ID)/terraform/state/$(TF_STATE_NAME)" \
		-backend-config="lock_address=https://$(GITLAB_HOSTNAME)/api/v4/projects/$(PROJECT_ID)/terraform/state/$(TF_STATE_NAME)/lock" \
		-backend-config="unlock_address=https://$(GITLAB_HOSTNAME)/api/v4/projects/$(PROJECT_ID)/terraform/state/$(TF_STATE_NAME)/lock" \
		-backend-config="username=$(call gitlab_username)" \
		-backend-config="password=$(call gitlab_token)" \
		-backend-config="lock_method=POST" \
		-backend-config="unlock_method=DELETE" \
		-backend-config="retry_wait_min=5" \
		$(ARGS)
	@$(call done,init)

ACTIONS += format~init ## formats terraform files
$(ACTION)/format: $(call git_deps,\.((tf)|(hcl))$$)
	@$(TERRAFORM) fmt $(ARGS)
	@$(call done,format)

ACTIONS += lint~format ## lints terraform files
$(ACTION)/lint: $(call git_deps,\.((tf)|(hcl))$$)
	@$(TERRAFORM) fmt -check $(ARGS)
	@$(call done,lint)

ACTIONS += plan~format ## creates terraform plan
$(ACTION)/plan: $(call git_deps,\.((tf)|(hcl))$$)
	@$(CD) $(TF_ROOT) && $(TERRAFORM) plan $(TERRAFORM_INPUT_FLAG) -out=tfplan $(ARGS)
	@$(call done,plan)

ACTIONS += apply~plan ## applies terraform infrastructure
$(ACTION)/apply: $(call git_deps,\.((tf)|(hcl))$$)
	@$(CD) $(TF_ROOT) && $(TERRAFORM) apply $(TERRAFORM_INPUT_FLAG) $(TERRAFORM_AUTO_APPROVE_FLAG) \
		$$([ -f tfplan ] && $(ECHO) tfplan || $(TRUE)) $(ARGS)
	@$(call done,apply)

ACTIONS += destroy~format ## destroys terraform infrastructure
$(ACTION)/destroy: $(call git_deps,\.((tf)|(hcl))$$)
	@$(CD) $(TF_ROOT) && $(TERRAFORM) destroy $(ARGS)
	@$(call done,destroy)

ACTIONS += refresh~format ## refreshes terraform state to match physical resources
$(ACTION)/refresh: $(call git_deps,\.((tf)|(hcl))$$)
	@$(CD) $(TF_ROOT) && $(TERRAFORM) refresh $(ARGS)
	@$(call done,refresh)

.PHONY: kubeconfig
kubeconfig: ## authenticate local environment with the eks cluster
	@$(AWS) eks update-kubeconfig --region $(AWS_REGION) --name $(EKS_CLUSTER)
	@export KUBE_CONTEXT=$$($(AWS) eks update-kubeconfig --region $(AWS_REGION) --name $(EKS_CLUSTER) | \
		$(GREP) -oE 'arn:aws:eks:[^ ]+') && \
		($(CAT) default.env | $(GREP) -E '^KUBE_CONTEXT=' && \
			($(CAT) default.env | $(SED) "s|\(KUBE_CONTEXT=\).*|\1$$KUBE_CONTEXT|g") || \
			$(ECHO) KUBE_CONTEXT=$$KUBE_CONTEXT >> default.env) && \
		$(KUBECTX) $(KUBE_CONTEXT)

.PHONY: clean
clean: ##
	-@$(GIT) clean -fXd \
		$(MKPM_GIT_CLEAN_FLAGS) \
		$(call git_clean_flags,.terraform) \
		$(NOFAIL)

.PHONY: purge
purge: clean ##
	@$(GIT) clean -fXd

.PHONY: count
count:
	@$(CLOC) $(shell $(GIT) ls-files)

define gitlab_username
$(shell $(CAT) $(HOME)/.docker/config.json | \
	$(JQ) -r '.auths["registry.gitlab.com"].auth' | $(BASE64) -d | $(CUT) -d: -f1)
endef

define gitlab_token
$(shell $(CAT) $(HOME)/.docker/config.json | \
	$(JQ) -r '.auths["registry.gitlab.com"].auth' | $(BASE64) -d | $(CUT) -d: -f2)
endef

-include $(call actions,$(ACTIONS))

endif
