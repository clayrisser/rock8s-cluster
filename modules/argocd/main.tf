resource "kubectl_manifest" "namespace" {
  count     = var.enabled ? 1 : 0
  yaml_body = <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: ${var.namespace}
EOF
}

resource "kubectl_manifest" "deploykf-assets-pvc" {
  count     = var.enabled ? 1 : 0
  yaml_body = <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: argocd-deploykf-plugin-assets
  namespace: ${var.namespace}
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF
  depends_on = [
    kubectl_manifest.namespace
  ]
}

resource "helm_release" "this" {
  count      = var.enabled ? 1 : 0
  repository = "https://argoproj.github.io/argo-helm"
  version    = var.chart_version
  chart      = "argo-cd"
  name       = "argocd"
  namespace  = var.namespace
  values = [<<EOF
global:
  securityContext:
    fsGroup: 999
configs:
  params:
    server.disable.auth: true
  cmp:
    create: true
    plugins:
      deploykf:
        parameters:
          static:
            - name: output_kustomize_path
              title: OUTPUT - KUSTOMIZE PATH
              tooltip: the path under 'deploykf generate --output-dir' at which to run 'kusomtize build'
              collectionType: string
            - name: output_helm_path
              title: OUTPUT - HELM PATH
              tooltip: the path under 'deploykf generate --output-dir' at which to run 'helm template'
              collectionType: string
            - name: output_helm_values_files
              title: OUTPUT - HELM VALUES FILES
              tooltip: a list of paths under 'output_helm_path' with values files to use with 'helm template'
              collectionType: array
            - name: source_version
              title: SOURCE VERSION
              tooltip: the '--source-version' to use with with the 'deploykf generate' command (mutually exclusive with `source_path`)
              collectionType: string
            - name: source_path
              title: SOURCE PATH
              tooltip: the '--source-path' to use with the 'deploykf generate' command (mutually exclusive with `source_version`)
              collectionType: string
            - name: values_files
              title: VALUES FILES
              tooltip: a list of paths (under the configured repo path) of '--values' files to use with 'deploykf generate'
              collectionType: array
            - name: values
              title: VALUES
              tooltip: a string containing the contents of a '--values' file to use with 'deploykf generate'
              collectionType: string
        init:
          command:
            - "/bin/bash"
            - "-c"
          args:
            - |
              set -eo pipefail
              if [[ -n "$PARAM_SOURCE_VERSION" && -n "$PARAM_SOURCE_PATH" ]]; then
                  echo "ERROR: both 'source_version' and 'source_path' were set, but we require exactly one" >&2
                  exit 1
              elif [[ -z "$PARAM_SOURCE_VERSION" && -z "$PARAM_SOURCE_PATH" ]]; then
                  echo "ERROR: neither of 'source_version' of 'source_path' were set, but we require exactly one" >&2
                  exit 1
              fi
              if [[ -n "$PARAM_OUTPUT_KUSTOMIZE_PATH" && -n "$PARAM_OUTPUT_HELM_PATH" ]]; then
                  echo "ERROR: both 'output_kustomize_path' and 'output_helm_path' were set, but we require exactly one" >&2
                  exit 1
              fi
              if [[ -z "$PARAM_OUTPUT_KUSTOMIZE_PATH" && -z "$PARAM_OUTPUT_HELM_PATH" ]]; then
                  PARAM_OUTPUT_KUSTOMIZE_PATH="./argocd/"
              fi
              DKF_ARGS=()
              OUTPUT_DIR="./__PLUGIN_GENERATOR_OUTPUT__"
              DKF_ARGS+=("--output-dir" "$OUTPUT_DIR")
              if [[ -n "$PARAM_SOURCE_VERSION" ]]; then
                  DKF_ARGS+=("--source-version" "$PARAM_SOURCE_VERSION")
              fi
              if [[ -n "$PARAM_SOURCE_PATH" ]]; then
                  DKF_ARGS+=("--source-path" "$PARAM_SOURCE_PATH")
              fi
              for env_var in $${!PARAM_VALUES_FILES_@}
              do
                  VALUES_FILE_PATH="$${!env_var}"
                  if [[ ! -f "$VALUES_FILE_PATH" ]]; then
                      echo "ERROR: the provided values file '$VALUES_FILE_PATH' does not exist" >&2
                      exit 1
                  fi
                  DKF_ARGS+=("--values" "$VALUES_FILE_PATH")
              done
              if [[ -n "$PARAM_VALUES" ]]; then
                  USER_VALUES_FILE_PATH="./__PLUGIN_USER_VALUES__.yaml"
                  echo "$PARAM_VALUES" > "$USER_VALUES_FILE_PATH"
                  DKF_ARGS+=("--values" "$USER_VALUES_FILE_PATH")
              fi
              REQUIRED_VALUES='{"argocd":{"source":{"plugin":{"enabled":true}}}}'
              REQUIRED_VALUES_FILE_PATH="./__PLUGIN_REQUIRED_VALUES__.yaml"
              echo "$REQUIRED_VALUES" > "$REQUIRED_VALUES_FILE_PATH"
              DKF_ARGS+=("--values" "$REQUIRED_VALUES_FILE_PATH")
              deploykf generate "$${DKF_ARGS[@]}"
              if [[ -n "$PARAM_OUTPUT_KUSTOMIZE_PATH" ]]; then
                  OUTPUT_KUSTOMIZE_PATH=$(realpath "$OUTPUT_DIR/$PARAM_OUTPUT_KUSTOMIZE_PATH")
                  if [[ ! -d "$OUTPUT_KUSTOMIZE_PATH" ]]; then
                      echo "ERROR: the provided 'output_kustomize_path' '$OUTPUT_KUSTOMIZE_PATH' does not exist" >&2
                      exit 1
                  fi
              fi
              if [[ -n "$PARAM_OUTPUT_HELM_PATH" ]]; then
                  OUTPUT_HELM_PATH=$(realpath "$OUTPUT_DIR/$PARAM_OUTPUT_HELM_PATH")
                  if [[ ! -d "$OUTPUT_HELM_PATH" ]]; then
                      echo "ERROR: the provided 'output_helm_path' '$OUTPUT_HELM_PATH' does not exist" >&2
                      exit 1
                  fi
                  helm dependency list --max-col-width 10000 "$OUTPUT_HELM_PATH" | awk 'NR>1 {print $1,$3}' | while read -r name url; do
                      if [[ -n "$name" && -n "$url" ]]; then
                          helm repo add "$name" "$url" --insecure-skip-tls-verify
                      fi
                  done
                  helm dependency build "$OUTPUT_HELM_PATH"
              fi
        generate:
          command:
            - "/bin/bash"
            - "-c"
          args:
            - |
              set -eo pipefail
              if [[ -z "$PARAM_OUTPUT_KUSTOMIZE_PATH" && -z "$PARAM_OUTPUT_HELM_PATH" ]]; then
                  PARAM_OUTPUT_KUSTOMIZE_PATH="./argocd/"
              fi
              OUTPUT_DIR="./__PLUGIN_GENERATOR_OUTPUT__"
              if [[ -n "$PARAM_OUTPUT_KUSTOMIZE_PATH" ]]; then
                  OUTPUT_KUSTOMIZE_PATH=$(realpath "$OUTPUT_DIR/$PARAM_OUTPUT_KUSTOMIZE_PATH")
                  kubectl kustomize "$OUTPUT_KUSTOMIZE_PATH"
              fi
              if [[ -n "$PARAM_OUTPUT_HELM_PATH" ]]; then
                  OUTPUT_HELM_PATH=$(realpath "$OUTPUT_DIR/$PARAM_OUTPUT_HELM_PATH")
                  HELM_ARGS=()
                  if [[ -n "$ARGOCD_APP_NAME" ]]; then
                      HELM_ARGS+=("--name-template" "$ARGOCD_APP_NAME")
                  fi
                  if [[ -n "$ARGOCD_APP_NAMESPACE" ]]; then
                      HELM_ARGS+=("--namespace" "$ARGOCD_APP_NAMESPACE")
                  fi
                  if [[ -n "$KUBE_VERSION" ]]; then
                      HELM_ARGS+=("--kube-version" "$KUBE_VERSION")
                  fi
                  for env_var in $${!PARAM_OUTPUT_HELM_VALUES_FILES_@}
                  do
                      HELM_VALUES_FILE_PATH=$(realpath "$OUTPUT_HELM_PATH/$${!env_var}")
                      if [[ -f "$HELM_VALUES_FILE_PATH" ]]; then
                          HELM_ARGS+=("--values" "$HELM_VALUES_FILE_PATH")
                      fi
                  done
                  if [[ -n "$KUBE_API_VERSIONS" ]]; then
                      IFS=',' read -ra KUBE_API_VERSIONS_ARRAY <<< "$KUBE_API_VERSIONS"
                      for KUBE_API_VERSION in "$${KUBE_API_VERSIONS_ARRAY[@]}"; do
                          HELM_ARGS+=("--api-versions" "$KUBE_API_VERSION")
                      done
                  fi
                  HELM_ARGS+=("--include-crds")
                  helm template "$OUTPUT_HELM_PATH" "$${HELM_ARGS[@]}"
              fi
repoServer:
  useEphemeralHelmWorkingDir: true
  initContainers:
    - name: deploykf-plugin-setup--kubectl
      image: docker.io/bitnami/kubectl:1.26.7
      command:
        - "/bin/sh"
        - "-c"
      args:
        - |
          echo "copying 'kubectl' binary to shared volume..."
          cp -f "$(which kubectl)" /tools/kubectl
      volumeMounts:
        - name: deploykf-plugin-tools
          mountPath: /tools
    - name: deploykf-plugin-setup--helm
      image: docker.io/alpine/helm:3.12.2
      command:
        - "/bin/sh"
        - "-c"
      args:
        - |
          echo "copying 'helm' binary to shared volume..."
          cp -f "$(which helm)" /tools/helm
      volumeMounts:
        - name: deploykf-plugin-tools
          mountPath: /tools
    - name: deploykf-plugin-setup--deploykf
      image: ghcr.io/deploykf/cli:0.1.2
      command:
        - "/bin/sh"
        - "-c"
      args:
        - |
          echo "copying 'deploykf' binary to shared volume..."
          cp -f "$(which deploykf)" /tools/deploykf
      volumeMounts:
        - name: deploykf-plugin-tools
          mountPath: /tools
  extraContainers:
    - name: deploykf-plugin
      image: docker.io/buildpack-deps:bookworm-curl
      securityContext:
        runAsNonRoot: true
        runAsUser: 999
      command:
        - "/var/run/argocd/argocd-cmp-server"
      args:
        - "--loglevel"
        - "info"
      env:
        - name: HELM_CACHE_HOME
          value: "/helm-working-dir"
        - name: HELM_CONFIG_HOME
          value: "/helm-working-dir"
        - name: HELM_DATA_HOME
          value: "/helm-working-dir"
      volumeMounts:
        - name: var-files
          mountPath: /var/run/argocd
        - name: plugins
          mountPath: /home/argocd/cmp-server/plugins
        - name: deploykf-plugin-tools
          mountPath: /usr/local/bin
        - name: argocd-cmp-cm
          mountPath: /home/argocd/cmp-server/config/plugin.yaml
          subPath: deploykf.yaml
        - name: deploykf-plugin-assets
          mountPath: /.deploykf/assets
        - name: helm-working-dir
          mountPath: /helm-working-dir
  volumes:
    - name: argocd-cmp-cm
      configMap:
        name: argocd-cmp-cm
    - name: deploykf-plugin-tools
      emptyDir: {}
    - name: deploykf-plugin-assets
      persistentVolumeClaim:
        claimName: argocd-deploykf-plugin-assets
EOF
    ,
    var.values
  ]
  depends_on = [
    kubectl_manifest.deploykf-assets-pvc
  ]
}
