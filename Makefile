# File: /Makefile
# Project: kops
# File Created: 27-01-2022 11:41:37
# Author: Clay Risser
# -----
# Last Modified: 26-06-2023 12:31:00
# Modified By: Clay Risser
# -----
# Risser Labs LLC (c) Copyright 2022

include mkpm.mk
ifneq (,$(MKPM_READY))
include $(MKPM)/gnu
include $(MKPM)/mkchain
include $(MKPM)/dotenv

export TF_STATE_NAME ?= $(CLUSTER_PREFIX)-$(ITERATION)
export TF_ROOT ?= main
export TF_PLAN_JSON ?= $(PROJECT_ROOT)/$(TF_ROOT)/tfplan.json
export CLUSTER_NAME ?= $(CLUSTER_PREFIX)-$(ITERATION).$(DNS_ZONE)

include $(PROJECT_ROOT)/gitlab.mk
include $(PROJECT_ROOT)/aws.mk
include $(PROJECT_ROOT)/terraform.mk

export AWS ?= aws
export CLOC ?= cloc
export CURL ?= curl
export KOPS ?= kops
export KUBECTL ?= $(call ternary,kubectl -h,kubectl,true)
export KUBECTX ?= $(call ternary,kubectx -h,kubectx,$(call ternary,kubectl ctx -h,kubectl ctx,true))
export SSH ?= ssh
export SSH_KEYGEN ?= ssh-keygen
export TERRAFORM ?= terraform

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
	@$(CD) $(TF_ROOT) && \
		RM_RECORDS=$$($(TERRAFORM) state list | \
		$(GREP) '^\(kubernetes_\|rancher2_\|helm_\|null_resource\.\|kubectl_\|data\.\|time_sleep\.\|module\.\)' | \
		$(GREP) -v '^\(module\.vpc\.\)' $(NOFAIL)) && \
		[ "$$RM_RECORDS" = "" ] && $(TRUE) || $(TERRAFORM) state rm $$RM_RECORDS && \
		$(TERRAFORM) destroy $(TERRAFORM_INPUT_FLAG) $(TERRAFORM_AUTO_APPROVE_FLAG) $(ARGS)
	@$(call done,destroy)

ACTIONS += refresh~format ## refreshes terraform state to match physical resources
$(ACTION)/refresh: $(call git_deps,\.((tf)|(hcl))$$)
	@$(CD) $(TF_ROOT) && $(TERRAFORM) refresh $(ARGS)
	@$(call done,refresh)

.PHONY: allow-destroy
allow-destroy: ## allow resource to be destroyed
	@$(call prevent_destroy,false)

.PHONY: prevent-destroy
prevent-destroy: ## prevent resources from being destroyed
	@$(call prevent_destroy,true)

.PHONY: kubeconfig
kubeconfig: ## authenticate local environment with the kube cluster
	@$(KOPS) export kubeconfig '$(CLUSTER_NAME)' \
		--state s3://$(CLUSTER_NAME)/kops \
		--admin \
		--kubeconfig $(HOME)/.kube/config
	@export KUBE_CONTEXT=$(CLUSTER_NAME) && \
		[ "$$($(CAT) default.env | $(GREP) -E '^KUBE_CONTEXT=[^ ]+')" = "KUBE_CONTEXT=$$KUBE_CONTEXT" ] && \
			$(ECHO) $(TRUE) || \
		($(CAT) default.env | $(GREP) -E '^KUBE_CONTEXT=' $(NOOUT) && \
			($(SED) -i "s|\(KUBE_CONTEXT=\).*|\1$$KUBE_CONTEXT|g" default.env) || \
			$(ECHO) KUBE_CONTEXT=$$KUBE_CONTEXT >> default.env) && \
		$(KUBECTX) $(KUBE_CONTEXT)

GROUP_NAME ?= rock8s
USER_NAME ?= $(KUBE_CONTEXT)
.PHONY: create-aws-user
create-aws-user:
	-@$(AWS) iam create-group --group-name $(GROUP_NAME)
	-@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --group-name $(GROUP_NAME)
	-@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess --group-name $(GROUP_NAME)
	-@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --group-name $(GROUP_NAME)
	-@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/IAMFullAccess --group-name $(GROUP_NAME)
	-@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess --group-name $(GROUP_NAME)
	-@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonSQSFullAccess --group-name $(GROUP_NAME)
	-@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess --group-name $(GROUP_NAME)
	@$(AWS) iam create-user --user-name $(USER_NAME)
	@$(AWS) iam add-user-to-group --user-name $(USER_NAME) --group-name $(GROUP_NAME)
	@$(AWS) iam create-access-key --user-name $(USER_NAME)

.PHONY: clean
clean: ## clean repo
	-@$(GIT) clean -fXd \
		$(MKPM_GIT_CLEAN_FLAGS) \
		$(call git_clean_flags,.terraform) \
		$(call git_clean_flags,.env) \
		$(NOFAIL)

.PHONY: purge
purge: clean ## purge repo
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
