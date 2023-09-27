OLM_VERSION ?= 0.25.0

ARTIFACTS += $(ROOTDIR)/modules/olm/artifacts/olm/crds.yaml
$(ROOTDIR)/modules/olm/artifacts/olm/crds.yaml:
	@mkdir -p $(@D)
	@$(DOWNLOAD) \
		https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v$(OLM_VERSION)/crds.yaml > $@

ARTIFACTS += $(ROOTDIR)/modules/olm/artifacts/olm/olm.yaml
$(ROOTDIR)/modules/olm/artifacts/olm/olm.yaml:
	@mkdir -p $(@D)
	@$(DOWNLOAD) \
		https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v${OLM_VERSION}/olm.yaml > $@
