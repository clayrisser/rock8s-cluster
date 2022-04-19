# File: /Makefile
# Project: eks
# File Created: 27-01-2022 11:41:37
# Author: Clay Risser
# -----
# Last Modified: 19-04-2022 14:53:49
# Modified By: Clay Risser
# -----
# Risser Labs LLC (c) Copyright 2022

include mkpm.mk
ifneq (,$(MKPM_READY))
include $(MKPM)/gnu
include $(MKPM)/mkchain
include $(MKPM)/dotenv

export TF_STATE_NAME ?= main
export TF_ROOT ?= main
export TF_PLAN_JSON ?= $(PROJECT_ROOT)/$(TF_ROOT)/tfplan.json

include $(PROJECT_ROOT)/gitlab.mk
include $(PROJECT_ROOT)/aws.mk
include $(PROJECT_ROOT)/terraform.mk

$(info AWS_PROFILE $(AWS_PROFILE))
$(info AWS_ACCESS_KEY_ID $(AWS_ACCESS_KEY_ID))
$(info AWS_SECRET_ACCESS_KEY $(AWS_SECRET_ACCESS_KEY))

export AWS ?= aws
export CLOC ?= cloc
export TERRAFORM ?= terraform
export SSH_KEYGEN ?= ssh-keygen
export KUBECTX ?= $(call ternary,kubectx -h,kubectx,$(call ternary,kubectl ctx -h,kubectl ctx,true))
export KUBECTL ?= $(call ternary,kubectl -h,kubectl,true)
export CURL ?= curl
export SSH ?= ssh

ifneq (,$(CI))
	TERRAFORM_INPUT_FLAG := -input=false
	TERRAFORM_AUTO_APPROVE_FLAG := -auto-approve
endif

ACTIONS += init ## initializes terraform
$(ACTION)/init: $(TF_ROOT)/versions.tf $(TF_ROOT)/backend.tf
	@$(CD) $(TF_ROOT) && $(TERRAFORM) init $(TERRAFORM_INPUT_FLAG) -reconfigure $(ARGS)
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
	@$(CD) $(TF_ROOT) && $(TERRAFORM) plan $(TERRAFORM_INPUT_FLAG) -out=tfplan.cache $(ARGS) && \
		$(TERRAFORM) show -json tfplan.cache | jq -r '$(JQ_PLAN)' > $(TF_PLAN_JSON)
	@$(CAT) $(TF_PLAN_JSON) | $(JQ)
	@$(call done,plan)

ACTIONS += apply~plan ## applies terraform infrastructure
$(ACTION)/apply: $(call git_deps,\.((tf)|(hcl))$$)
	@$(CD) $(TF_ROOT) && $(TERRAFORM) apply $(TERRAFORM_INPUT_FLAG) $(TERRAFORM_AUTO_APPROVE_FLAG) \
		$$([ -f tfplan.cache ] && $(ECHO) tfplan.cache || $(TRUE)) $(ARGS)
	@$(call done,apply)

ACTIONS += destroy~format ## destroys terraform infrastructure
$(ACTION)/destroy: $(call git_deps,\.((tf)|(hcl))$$)
	@$(CD) $(TF_ROOT) && $(TERRAFORM) destroy $(TERRAFORM_INPUT_FLAG) $(TERRAFORM_AUTO_APPROVE_FLAG) $(ARGS)
	@$(call done,destroy)

ACTIONS += refresh~format ## refreshes terraform state to match physical resources
$(ACTION)/refresh: $(call git_deps,\.((tf)|(hcl))$$)
	@$(CD) $(TF_ROOT) && $(TERRAFORM) refresh $(ARGS)
	@$(call done,refresh)

.PHONY: kubeconfig
kubeconfig: ## authenticate local environment with the eks cluster
	@$(AWS) eks update-kubeconfig --region $(AWS_REGION) --name $(EKS_CLUSTER)-$(ITERATION)
	@export KUBE_CONTEXT=$$($(AWS) eks update-kubeconfig --region $(AWS_REGION) --name $(EKS_CLUSTER)-$(ITERATION) | \
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

.PHONY: terraform
terraform:
	@$(CD) $(TF_ROOT) && $(TERRAFORM) $(ARGS)

define JQ_PLAN
( \
    [.resource_changes[]?.change.actions?] | flatten \
) | { \
    "create":(map(select(.=="create")) | length), \
    "update":(map(select(.=="update")) | length), \
    "delete":(map(select(.=="delete")) | length) \
}
endef

-include $(call actions,$(ACTIONS))

endif
