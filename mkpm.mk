# File: /mkpm.mk
# Project: eks
# File Created: 27-01-2022 11:45:11
# Author: Clay Risser
# -----
# Last Modified: 27-06-2022 10:52:49
# Modified By: Clay Risser
# -----
# Risser Labs LLC (c) Copyright 2022

export MKPM_PACKAGES_DEFAULT := \
	dotenv=0.0.9 \
	gnu=0.0.3 \
	mkchain=0.1.0

export MKPM_REPO_DEFAULT := \
	https://gitlab.com/risserlabs/community/mkpm-stable.git

############# MKPM BOOTSTRAP SCRIPT BEGIN #############
MKPM_BOOTSTRAP := https://gitlab.com/api/v4/projects/29276259/packages/generic/mkpm/0.2.0/bootstrap.mk
export PROJECT_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
NULL := /dev/null
TRUE := true
ifneq ($(patsubst %.exe,%,$(SHELL)),$(SHELL))
	NULL = nul
	TRUE = type nul
endif
-include $(PROJECT_ROOT)/.mkpm/.bootstrap.mk
$(PROJECT_ROOT)/.mkpm/.bootstrap.mk:
	@mkdir $(@D) 2>$(NULL) || $(TRUE)
	@$(shell curl --version >$(NULL) 2>$(NULL) && \
			echo curl -L -o || \
			echo wget --content-on-error -O) \
		$@ $(MKPM_BOOTSTRAP) >$(NULL)
############## MKPM BOOTSTRAP SCRIPT END ##############
