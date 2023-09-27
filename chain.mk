# cached dependency chains that tracks changes on individual files
.NOTPARALLEL:
.ONESHELL:
.POSIX:
.SECONDEXPANSION:
.SILENT:
export ROOTDIR ?= $(CURDIR)
CHAIN_CACHE ?= $(ROOTDIR)/main/.terraform/.chain
NOFAIL := 2>/dev/null || true
CHAIN_ACTIONS := $(CHAIN_CACHE)/actions
CHAIN_ID := $(shell echo $(CURDIR) | shasum | cut -d' ' -f1)
CHAIN_DONE := $(CHAIN_CACHE)/$(CHAIN_ID)/done
ACTION := $(CHAIN_DONE)
CHAIN_CLEAN := rm -rf $(CHAIN_CACHE) $(NOFAIL)
define _ACTION_TEMPLATE
.PHONY: {{ACTION}} +{{ACTION}} _{{ACTION}} ~{{ACTION}}
{{ACTION}}: _{{ACTION}} ~{{ACTION}}
~{{ACTION}}: {{ACTION_DEPENDENCY}} $$({{ACTION_UPPER}}_TARGETS) $$(ACTION)/{{ACTION}}
+{{ACTION}}: _{{ACTION}} $$({{ACTION_UPPER}}_TARGETS) $$(ACTION)/{{ACTION}}
_{{ACTION}}:
	@rm -rf $$(CHAIN_DONE)/{{ACTION}}
endef
export _ACTION_TEMPLATE
.PHONY: $(CHAIN_ACTIONS)/%
$(CHAIN_ACTIONS)/%:
	@mkdir -p "$(@D)" "$(CHAIN_DONE)"
	@ACTION=$$(echo $* | grep -oE "^[^~]+") && \
		ACTION_DEPENDENCY=$$(echo $* | grep -oE "~[^~]+$$" 2>/dev/null || true) && \
		ACTION_UPPER=$$(echo $$ACTION | tr '[:lower:]' '[:upper:]') && \
		echo "$${_ACTION_TEMPLATE}" | sed "s|{{ACTION}}|$${ACTION}|g" | \
		sed "s|{{ACTION_DEPENDENCY}}|$${ACTION_DEPENDENCY}|g" | \
		sed "s|{{ACTION_UPPER}}|$${ACTION_UPPER}|g" > $@
define chain
$(patsubst %,$(CHAIN_ACTIONS)/%,$(ACTIONS))
endef
define done
mkdir -p $(dir $1) && touch -m $1
endef
define reset
$(MAKE) -s _$1 && \
rm -rf $(ACTION)/$1 $(NOFAIL)
endef
define git_deps
$(shell (git ls-files && (git lfs ls-files | cut -d' ' -f3)) | sort | uniq -u | grep -E "$1" $(NOFAIL))
endef
$(ROOTDIR)/.env: $(ROOTDIR)/default.env
	@if [ ! -f "$@" ] || [ "$<" -nt "$@" ]; then cp $< $@; fi
$(CHAIN_CACHE)/env: $(ROOTDIR)/.env
	@mkdir -p $(@D)
	@awk -F= ' \
		BEGIN { inMultiline=0; quoteType="" } \
		/^[[:space:]]*#/ || /^[[:space:]]*$$/ { print; next } \
		inMultiline && $$0 ~ quoteType "$$" { print; inMultiline=0; next } \
		inMultiline { print; next } \
		($$2 ~ /^"[^"]*$$/) || ($$2 ~ /^'\''[^'\'']*$$/) { \
			print "export " $$0; \
			inMultiline=1; \
			quoteType = substr($$2, 1, 1); \
			next \
		} \
		{ print "export " $$0 }' $< > $@
$(CHAIN_CACHE)/mkenv: $(CHAIN_CACHE)/env
	@mkdir -p $(@D)
	@rm $@ $(NOFAIL)
	@. $< && \
		for e in $$(cat $< | grep -oE '^export +[^=]+' | sed 's|^export \+||g'); do \
			echo "define $$e" && \
			eval "echo \"\$$$$e\"" && \
			echo endef && echo; \
		done > $@
-include $(CHAIN_CACHE)/mkenv
