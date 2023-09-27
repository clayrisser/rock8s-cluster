ifneq (,$(wildcard $(CURDIR)/artifacts/kubeconfig.json))
export ARGOCD_AUTH_PASSWORD ?= $(shell kubectl --kubeconfig $(KUBECONFIG_JSON) -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' 2>/dev/null | base64 --decode)
endif
