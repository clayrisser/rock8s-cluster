# File: /Makefile
# Project: kops
# File Created: 27-01-2022 11:41:37
# Author: Clay Risser
# -----
# Last Modified: 10-07-2023 15:07:40
# Modified By: Clay Risser
# -----
# BitSpur (c) Copyright 2022

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

IGNORE_DESTROY := \
	data\\. \
	helm_ \
	kubectl_ \
	kubernetes_ \
	module\\..*\\.helm_release \
	module\\..*\\.rancher2_ \
	null_resource\\. \
	rancher2_ \
	time_sleep\\.
ACTIONS += destroy~format ## destroys terraform infrastructure
$(ACTION)/destroy: $(call git_deps,\.((tf)|(hcl))$$)
	@$(CD) $(TF_ROOT) && \
		RM_RECORDS=$$($(TERRAFORM) state list | \
		$(GREP) '^\($(shell $(ECHO) $(IGNORE_DESTROY) | sed "s/ /\\\|/g")\)' $(NOFAIL)) && \
		[ "$$RM_RECORDS" = "" ] && $(TRUE) || $(TERRAFORM) state rm $$RM_RECORDS && \
		$(TERRAFORM) destroy $(TERRAFORM_INPUT_FLAG) $(TERRAFORM_AUTO_APPROVE_FLAG) $(ARGS)
	@for b in $$($(AWS) s3api list-buckets --query 'Buckets[].Name' --output text | $(TR) '\t' '\n' | $(GREP) $(shell $(ECHO) $(KUBE_CONTEXT) | $(SED) 's|\.|-|g')); do \
			$(AWS) s3 rb s3://$$b --force; \
		done
		for u in $$($(AWS) iam list-users --query 'Users[].UserName' --output text | $(TR) '\t' '\n' | $(GREP) $(KUBE_CONTEXT)); do \
			for k in $$($(AWS) iam list-access-keys --user-name $$u --query 'AccessKeyMetadata[].AccessKeyId' --output text); do \
				$(AWS) iam delete-access-key --user-name $$u --access-key-id $$k; \
			done; \
			for p in $$($(AWS) iam list-user-policies --user-name $$u --query 'PolicyNames[]' --output text); do \
				$(AWS) iam delete-user-policy --user-name $$u --policy-name $$p; \
			done; \
			$(AWS) iam delete-user --user-name $$u; \
		done
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

MAIN_BUCKET ?= $(shell $(ECHO) $(CLUSTER_NAME) | $(SED) 's|\.|-|g')
.PHONY: kubeconfig
kubeconfig: ## authenticate local environment with the kube cluster
	@$(KOPS) export kubeconfig '$(CLUSTER_NAME)' \
		--state s3://$(MAIN_BUCKET)/kops \
		--admin \
		--kubeconfig $(HOME)/.kube/config
	@export KUBE_CONTEXT=$(CLUSTER_NAME) && \
		[ "$$($(CAT) default.env | $(GREP) -E '^KUBE_CONTEXT=[^ ]+')" = "KUBE_CONTEXT=$$KUBE_CONTEXT" ] && \
			$(ECHO) $(TRUE) || \
		($(CAT) default.env | $(GREP) -E '^KUBE_CONTEXT=' $(NOOUT) && \
			($(SED) -i "s|\(KUBE_CONTEXT=\).*|\1$$KUBE_CONTEXT|g" default.env) || \
			$(ECHO) KUBE_CONTEXT=$$KUBE_CONTEXT >> default.env) && \
		$(KUBECTX) $(KUBE_CONTEXT)

.PHONY: upgrade
upgrade: ## upgrades terraform packages
	@$(CD) $(TF_ROOT) && $(TERRAFORM) init -upgrade $(ARGS)

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

GROUP_NAME ?= rock8s
USER_NAME ?= $(CLUSTER_PREFIX).$(DNS_ZONE)
.PHONY: prepare-aws
prepare-aws:
	-@$(AWS) iam create-group --group-name $(GROUP_NAME)
	-@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --group-name $(GROUP_NAME)
	-@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess --group-name $(GROUP_NAME)
	-@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --group-name $(GROUP_NAME)
	-@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/IAMFullAccess --group-name $(GROUP_NAME)
	-@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess --group-name $(GROUP_NAME)
	-@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonSQSFullAccess --group-name $(GROUP_NAME)
	-@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess --group-name $(GROUP_NAME)
	-@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly --group-name $(GROUP_NAME)
	-@$(AWS) iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess --group-name $(GROUP_NAME)
	-@( $(AWS) route53 list-hosted-zones | grep -q $(DNS_ZONE) && $(TRUE) ) || \
		$(AWS) route53 create-hosted-zone --name $(DNS_ZONE) --caller-reference $(shell date '+%s%N')
	@$(AWS) iam create-user --user-name $(USER_NAME)
	@$(AWS) iam add-user-to-group --user-name $(USER_NAME) --group-name $(GROUP_NAME)
	@$(AWS) iam create-access-key --user-name $(USER_NAME)

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
