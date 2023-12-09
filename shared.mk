# File: /shared.mk
# Project: rock8s-cluster
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

AWS ?= aws
AWSWEEPER ?= awsweeper
CLOC ?= cloc
CURL ?= curl
DOCKER_COMPOSE ?= docker-compose
JQ ?= jq
KOPS ?= kops
SSH ?= ssh
SSH_KEYGEN ?= ssh-keygen
TERRAFORM ?= terraform
DOWNLOAD := $(shell $(WHICH) curl $(NOOUT) && echo curl -L || echo wget -O-)

define ternary
$(shell $1 $(NOOUT) && $(ECHO) $2|| $(ECHO) $3)
endef

KUBECTL ?= $(call ternary,kubectl -h,kubectl,true)
KUBECTX ?= $(call ternary,kubectx -h,kubectx,$(call ternary,kubectl ctx -h,kubectl ctx,true))

MODULES := $(PROJECT_ROOT)/modules

export AWS_ACCOUNT_ID ?= $(shell aws sts get-caller-identity --query 'Account' --output text)

ifneq (,$(CI))
	TERRAFORM_INPUT_FLAG := -input=false
	TERRAFORM_AUTO_APPROVE_FLAG := -auto-approve
endif

define git_deps
$(shell ($(GIT) ls-files && ($(GIT) lfs ls-files | $(CUT) -d' ' -f3)) | $(SORT) | $(UNIQ) -u | $(GREP) -E "$1" $(NOFAIL))
endef

define set_kube_context
[ "$$(cat $1 | grep -E '^KUBE_CONTEXT=[^ ]+')" = "KUBE_CONTEXT=$$KUBE_CONTEXT" ] && \
true || \
(cat $1 | grep -E '^KUBE_CONTEXT=' $(NOOUT) && \
	(sed -i $(shell [ "$(shell uname)" = "Darwin" ] && echo '""' || true) \
		"s|\(KUBE_CONTEXT=\).*|\1$$KUBE_CONTEXT|g" $1) || \
	echo KUBE_CONTEXT=$$KUBE_CONTEXT >> $1)
endef

define JQ_PLAN
( \
    [.resource_changes[]?.change.actions?] | flatten \
) | { \
    "create":(map(select(.=="create")) | length), \
    "update":(map(select(.=="update")) | length), \
    "delete":(map(select(.=="delete")) | length) \
}
endef
