# File: /gitlab.mk
# Project: kops
# File Created: 26-06-2023 07:11:51
# Author: Clay Risser
# -----
# Last Modified: 27-06-2023 15:39:42
# Modified By: Clay Risser
# -----
# BitSpur (c) Copyright 2022 - 2023

export BASE64 ?= openssl base64

define gitlab_username
$(shell $(CAT) $(HOME)/.docker/config.json 2>$(NULL) | \
	$(JQ) -r '.auths["registry.gitlab.com"].auth' 2>$(NULL) | \
	$(BASE64) -d 2>$(NULL) | \
	$(CUT) -d: -f1 2>$(NULL))
endef

define gitlab_token
$(shell $(CAT) $(HOME)/.docker/config.json 2>$(NULL) | \
	$(JQ) -r '.auths["registry.gitlab.com"].auth' 2>$(NULL) | \
	$(BASE64) -d 2>$(NULL) | \
	$(CUT) -d: -f2 2>$(NULL))
endef

ifneq (,$(CI_JOB_TOKEN))
	TF_USERNAME := gitlab-ci-token
	TF_PASSWORD := $(CI_JOB_TOKEN)
else
ifneq (,$(GITLAB_REGISTRY_TOKEN))
	TF_USERNAME ?= $(GITLAB_REGISTRY_USERNAME)
	TF_PASSWORD ?= $(GITLAB_REGISTRY_TOKEN)
else
	TF_USERNAME ?= $(call gitlab_username)
	TF_PASSWORD ?= $(call gitlab_token)
endif
endif

ifeq (,$(TF_ADDRESS))
ifeq (,$(CI))
	TF_ADDRESS := https://$(GITLAB_HOSTNAME)/api/v4/projects/$(GITLAB_PROJECT_ID)/terraform/state/$(TF_STATE_NAME)
else
ifneq (,$(CI_PROJECT_ID))
	GITLAB_PROJECT_ID := $(CI_PROJECT_ID)
endif
	TF_IN_AUTOMATION=true
	TF_ADDRESS := $(CI_API_V4_URL)/projects/$(GITLAB_PROJECT_ID)/terraform/state/$(TF_STATE_NAME)
endif
endif

export TF_HTTP_ADDRESS ?= $(TF_ADDRESS)
export TF_HTTP_LOCK_ADDRESS ?= $(TF_ADDRESS)/lock
export TF_HTTP_LOCK_METHOD ?= POST
export TF_HTTP_UNLOCK_ADDRESS ?= $(TF_ADDRESS)/lock
export TF_HTTP_UNLOCK_METHOD ?= DELETE
export TF_HTTP_USERNAME ?= $(TF_USERNAME)
export TF_HTTP_PASSWORD ?= $(TF_PASSWORD)
export TF_HTTP_RETRY_WAIT_MIN ?= 5

export TF_VAR_CI_JOB_ID ?= $(CI_JOB_ID)
export TF_VAR_CI_COMMIT_SHA ?= $(CI_COMMIT_SHA)
export TF_VAR_CI_JOB_STAGE ?= $(CI_JOB_STAGE)
export TF_VAR_CI_PROJECT_ID ?= $(CI_PROJECT_ID)
export TF_VAR_CI_PROJECT_NAME ?= $(CI_PROJECT_NAME)
export TF_VAR_CI_PROJECT_NAMESPACE ?= $(CI_PROJECT_NAMESPACE)
export TF_VAR_CI_PROJECT_PATH ?= $(CI_PROJECT_PATH)
export TF_VAR_CI_PROJECT_URL ?= $(CI_PROJECT_URL)
