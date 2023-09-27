AWS ?= aws
AWSWEEPER ?= awsweeper
CAT ?= cat
CD ?= cd
CLOC ?= cloc
CURL ?= curl
CUT ?= cut
DOCKER_COMPOSE ?= docker-compose
ECHO ?= echo
GIT ?= git
GREP ?= grep
JQ ?= jq
KOPS ?= kops
SED ?= sed
SORT ?= sort
SSH ?= ssh
SSH_KEYGEN ?= ssh-keygen
TERRAFORM ?= terraform
TRUE ?= true
UNIQ ?= uniq
WHICH ?= command -v
NULL := /dev/null
NOOUT := >$(NULL) 2>&1
NOFAIL := 2>$(NULL) || true
DOWNLOAD := $(shell $(WHICH) curl $(NOOUT) && echo curl -L || echo wget -O-)

define git_deps
$(shell ($(GIT) ls-files && ($(GIT) lfs ls-files | $(CUT) -d' ' -f3)) | $(SORT) | $(UNIQ) -u | $(GREP) -E "$1" $(NOFAIL))
endef

define ternary
$(shell $1 $(NOOUT) && $(ECHO) $2|| $(ECHO) $3)
endef

define prevent_destroy
for f in $$($(GIT) ls-files | $(GREP) "\.tf$$"); do \
	$(SED) -i 's|\(prevent_destroy\s\+=\s\+\)\w\+|\1$1|g' $$f; \
done
endef

KUBECTL ?= $(call ternary,kubectl -h,kubectl,true)
KUBECTX ?= $(call ternary,kubectx -h,kubectx,$(call ternary,kubectl ctx -h,kubectl ctx,true))

ifneq (,$(CI))
	TERRAFORM_INPUT_FLAG := -input=false
	TERRAFORM_AUTO_APPROVE_FLAG := -auto-approve
endif

define JQ_PLAN
( \
    [.resource_changes[]?.change.actions?] | flatten \
) | { \
    "create":(map(select(.=="create")) | length), \
    "update":(map(select(.=="update")) | length), \
    "delete":(map(select(.=="delete")) | length) \
}
endef

define set_kube_context
[ "$$(cat $1 | grep -E '^KUBE_CONTEXT=[^ ]+')" = "KUBE_CONTEXT=$$KUBE_CONTEXT" ] && \
true || \
(cat $1 | grep -E '^KUBE_CONTEXT=' $(NOOUT) && \
	(sed -i $(shell [ "$(shell uname)" = "Darwin" ] && echo '""' || true) \
		"s|\(KUBE_CONTEXT=\).*|\1$$KUBE_CONTEXT|g" $1) || \
	echo KUBE_CONTEXT=$$KUBE_CONTEXT >> $1)
endef

MODULES := $(ROOTDIR)/modules
