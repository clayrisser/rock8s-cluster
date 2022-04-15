# File: /gitlab.mk
# Project: eks
# File Created: 15-04-2022 09:01:44
# Author: Clay Risser
# -----
# Last Modified: 15-04-2022 09:32:45
# Modified By: Clay Risser
# -----
# Risser Labs LLC (c) Copyright 2022

export BASE64 ?= openssl base64

define gitlab_username
$(shell $(CAT) $(HOME)/.docker/config.json | \
	$(JQ) -r '.auths["registry.gitlab.com"].auth' | $(BASE64) -d | $(CUT) -d: -f1)
endef

define gitlab_token
$(shell $(CAT) $(HOME)/.docker/config.json | \
	$(JQ) -r '.auths["registry.gitlab.com"].auth' | $(BASE64) -d | $(CUT) -d: -f2)
endef

TF_USERNAME ?= $(call gitlab_username)
TF_PASSWORD ?= $(call gitlab_token)

ifeq (,$(TF_USERNAME))
	TF_USERNAME := $(GITLAB_USER_LOGIN)
endif
ifeq (,$(TF_PASSWORD))
	TF_USERNAME := gitlab-ci-token
	TF_PASSWORD := $(CI_JOB_TOKEN)
endif

ifeq (,$(TF_ADDRESS))
ifeq (,$(CI))
	TF_ADDRESS := https://$(GITLAB_HOSTNAME)/api/v4/projects/$(PROJECT_ID)/terraform/state/$(TF_STATE_NAME)
else
	TF_IN_AUTOMATION=true
	TF_ADDRESS := $(CI_API_V4_URL)/projects/$(CI_PROJECT_ID)/terraform/state/$(TF_STATE_NAME)
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
