# File: /Makefile
# Project: main
# File Created: 27-09-2023 05:26:34
# Author: Clay Risser
# -----
# BitSpur (c) Copyright 2021 - 2023
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include $(MKPM)/mkpm
include $(MKPM)/gnu
include $(MKPM)/dotenv
include $(MKPM)/envcache
include $(MKPM)/chain

include $(PROJECT_ROOT)/gitlab.mk
include $(PROJECT_ROOT)/aws.mk
include $(PROJECT_ROOT)/terraform.mk

export TF_STATE_NAME ?= $(CLUSTER_PREFIX)-$(ITERATION)

include $(PROJECT_ROOT)/terraform.mk
include $(PROJECT_ROOT)/shared.mk

export CLUSTER_NAME ?= $(CLUSTER_PREFIX)-$(ITERATION).$(DNS_ZONE)
export CLUSTER_ENDPOINT ?= https://api.$(CLUSTER_NAME)
export AWS_IAM_ROLE_ADMIN_ARN ?= arn:aws:iam::$(AWS_ACCOUNT_ID):role/$(CLUSTER_NAME)

export KUBECONFIG_JSON := $(CURDIR)/artifacts/kubeconfig.json
_ := $(shell mkdir -p $(CURDIR)/artifacts && \
[ "$(CLUSTER_ENDPOINT)" != "" ] && cat $(CURDIR)/kubeconfig.json | \
sed 's|<CLUSTER_NAME>|$(CLUSTER_NAME)|g' | \
sed 's|<AWS_IAM_ROLE_ADMIN_ARN>|$(AWS_IAM_ROLE_ADMIN_ARN)|g' | \
sed 's|<CLUSTER_ENDPOINT>|$(CLUSTER_ENDPOINT)|g' > $(KUBECONFIG_JSON))

LOAD_MODULES ?= 1
include modules.mk

.PHONY: terraform
terraform:
	@$(TERRAFORM) $(TERRAFORM_ARGS)

ACTIONS += init ## initialize terraform
INIT_TARGETS := $(ARTIFACTS)
$(ACTION)/init: versions.tf backend.tf
	@$(TERRAFORM) init $(TERRAFORM_INPUT_FLAG) -reconfigure -upgrade $(INIT_ARGS)
	@$(call done,$@)

ACTIONS += format~init ## format terraform files
$(ACTION)/format: $(call git_deps,\.((tf))$$)
	@$(TERRAFORM) fmt $(FORMAT_ARGS)
	@$(call done,$@)

ACTIONS += lint~format ## lint terraform files
$(ACTION)/lint: $(call git_deps,\.((tf))$$)
	@$(TERRAFORM) fmt -check $(LINT_ARGS)
	@$(call done,$@)

ACTIONS += plan~format ## create terraform plan
$(ACTION)/plan: $(call git_deps,\.((tf))$$)
	@$(TERRAFORM) plan $(TERRAFORM_INPUT_FLAG) -out=tfplan.cache $(PLAN_ARGS) && \
		$(TERRAFORM) show -json tfplan.cache | $(JQ) -r '$(JQ_PLAN)'
	@$(call done,$@)

ACTIONS += apply~plan ## apply terraform infrastructure
$(ACTION)/apply: $(call git_deps,\.((tf))$$)
	@$(TERRAFORM) apply $(TERRAFORM_INPUT_FLAG) $(TERRAFORM_AUTO_APPROVE_FLAG) \
			$$([ -f tfplan.cache ] && echo tfplan.cache || true) $(APPLY_ARGS)
	@$(call done,$@)

ACTIONS += refresh~init ## refresh terraform state to match physical resources
$(ACTION)/refresh: $(call git_deps,\.((tf))$$)
	@$(TERRAFORM) refresh $(REFRESH_ARGS)
	@$(call done,$@)

IGNORE_DESTROY := \
	argocd_ \
	data\\. \
	helm_ \
	kubectl_ \
	kubernetes_ \
	kustomization_ \
	module\\..*\\.helm_ \
	module\\..*\\.helm_release \
	module\\..*\\.kubectl_ \
	module\\..*\\.kubernetes_ \
	module\\..*\\.kustomization_ \
	module\\..*\\.rancher2_ \
	module\\.csi-drivers\\..* \
	module\\.eks-blueprints-addons\\..* \
	module\\.karpenter\\..* \
	module\\.vpc\\..* \
	null_resource\\. \
	rancher2_ \
	time_sleep\\.
ACTIONS += destroy~format ## destroy terraform resources
$(ACTION)/destroy: $(call git_deps,\.((tf))$$)
ifneq ($(TERRAFORM_AUTO_APPROVE_FLAG),-auto-approve)
	@printf "Are you sure you want to destroy? [y/N] " && read ans && [ $${ans:-N} = y ]
endif
	@RM_RECORDS=$$($(TERRAFORM) state list | \
		$(GREP) '^\($(shell $(ECHO) $(IGNORE_DESTROY) | sed "s/ /\\\|/g")\)' $(NOFAIL)) && \
		[ "$$RM_RECORDS" = "" ] && $(TRUE) || $(TERRAFORM) state rm $$RM_RECORDS && \
		$(TERRAFORM) destroy $(TERRAFORM_INPUT_FLAG) -auto-approve $(ARGS) || $(TRUE)
	@export AWSWEEPER_FILE=$$(mktemp) && \
		cat $(PROJECT_ROOT)/awsweeper.yml | sed 's|<CLUSTER_NAME>|$(CLUSTER_NAME)|g' > $$AWSWEEPER_FILE && \
		$(AWSWEEPER) --force $$AWSWEEPER_FILE && \
		rm -f $$AWSWEEPER_FILE
	@$(call done,$@)

MAIN_BUCKET ?= $(shell $(ECHO) $(CLUSTER_NAME) | $(SED) 's|\.|-|g')
.PHONY: kubeconfig
kubeconfig: ## authenticate local environment with the kube cluster
	@$(KOPS) export kubeconfig '$(CLUSTER_NAME)' \
		--state s3://$(MAIN_BUCKET)/kops \
		--admin \
		--kubeconfig $(HOME)/.kube/config
	@export KUBE_CONTEXT=$(CLUSTER_NAME) && \
		$(call set_kube_context,$(PROJECT_ROOT)/default.env) && \
		$(call set_kube_context,$(PROJECT_ROOT)/.env)
	@$(KUBECTX) $(KUBE_CONTEXT)

.PHONY: kops
kops:
	@$(KOPS) --state s3://$(MAIN_BUCKET)/kops \
		--name '$(CLUSTER_NAME)' \
		$(KOPS_ARGS)

-include $(call chain)
