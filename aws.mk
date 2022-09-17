# File: /aws.mk
# Project: kops
# File Created: 19-04-2022 08:50:29
# Author: Clay Risser
# -----
# Last Modified: 17-09-2022 06:55:28
# Modified By: Clay Risser
# -----
# Risser Labs LLC (c) Copyright 2022

define aws_access_key_id
$(shell $(ECHO) $(shell $(CAT) $(HOME)/.aws/credentials 2>$(NULL)) 2>$(NULL) | \
	$(SED) 's/.\+\[$(AWS_PROFILE)\]//g' 2>$(NULL) | \
	$(GREP) -oE '^[^\[]+' 2>$(NULL) | \
	$(GREP) -oE 'aws_access_key_id = [^ ]+' 2>$(NULL) | \
	$(SED) 's|aws_access_key_id = ||g' 2>$(NULL))
endef

define aws_secret_access_key
$(shell $(ECHO) $(shell $(CAT) $(HOME)/.aws/credentials 2>$(NULL)) 2>$(NULL) | \
	$(SED) 's/.\+\[$(AWS_PROFILE)\]//g' 2>$(NULL) | \
	$(GREP) -oE '^[^\[]+' 2>$(NULL) | \
	$(GREP) -oE 'aws_secret_access_key = [^ ]+' 2>$(NULL) | \
	$(SED) 's|aws_secret_access_key = ||g' 2>$(NULL))
endef

ifneq (,$(AWS_ACCESS_KEY_ID))
	undefine AWS_PROFILE
endif

ifeq (,$(AWS_ACCESS_KEY_ID))
	AWS_ACCESS_KEY_ID := $(call aws_access_key_id)
endif
export AWS_ACCESS_KEY_ID

ifeq (,$(AWS_SECRET_ACCESS_KEY))
	AWS_SECRET_ACCESS_KEY := $(call aws_secret_access_key)
endif
export AWS_SECRET_ACCESS_KEY

export AWS_DEFAULT_REGION=$(AWS_REGION)
