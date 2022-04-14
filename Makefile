# File: /Makefile
# Project: eks
# File Created: 27-01-2022 11:41:37
# Author: Clay Risser
# -----
# Last Modified: 14-04-2022 08:40:11
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

ifneq (,$(CI))
	TERRAFORM_INPUT_FLAG := -input=false
	TERRAFORM_AUTO_APPROVE_FLAG := -auto-approve
endif

ACTIONS += init ## initializes terraform
$(ACTION)/init: main/versions.tf .terraform/terraform.tfstate
	@$(CD) main && $(TERRAFORM) init $(TERRAFORM_INPUT_FLAG) $(ARGS)
	@$(call done,init)
.terraform/terraform.tfstate:
	@$(TERRAFORM) init -reconfigure \
		-backend-config="address=https://$(GITLAB_HOSTNAME)/api/v4/projects/$(PROJECT_ID)/terraform/state/$(STATE_NAME)" \
		-backend-config="lock_address=https://$(GITLAB_HOSTNAME)/api/v4/projects/$(PROJECT_ID)/terraform/state/$(STATE_NAME)/lock" \
		-backend-config="unlock_address=https://$(GITLAB_HOSTNAME)/api/v4/projects/$(PROJECT_ID)/terraform/state/$(STATE_NAME)/lock" \
		-backend-config="username=$$($(MAKE) -s gitlab-username)" \
		-backend-config="password=$$($(MAKE) -s gitlab-token)" \
		-backend-config="lock_method=POST" \
		-backend-config="unlock_method=DELETE" \
		-backend-config="retry_wait_min=5"

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
	@$(CD) main && $(TERRAFORM) plan $(TERRAFORM_INPUT_FLAG) -out=tfplan $(ARGS)
	@$(call done,plan)

ACTIONS += apply~plan ## applies terraform infrastructure
$(ACTION)/apply: $(call git_deps,\.((tf)|(hcl))$$)
	@$(CD) main && $(TERRAFORM) apply $(TERRAFORM_INPUT_FLAG) $(TERRAFORM_AUTO_APPROVE_FLAG) \
		$$([ -f tfplan ] && $(ECHO) tfplan || $(TRUE)) $(ARGS)
	@$(call done,apply)

ACTIONS += destroy~format ## destroys terraform infrastructure
$(ACTION)/destroy: $(call git_deps,\.((tf)|(hcl))$$)
	@$(CD) main && $(TERRAFORM) destroy $(ARGS)
	@$(call done,destroy)

ACTIONS += refresh~format ## refreshes terraform state to match physical resources
$(ACTION)/refresh: $(call git_deps,\.((tf)|(hcl))$$)
	@$(CD) main && $(TERRAFORM) refresh $(ARGS)
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

-include $(call actions,$(ACTIONS))

endif
