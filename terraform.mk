# File: /terraform.mk
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

export TF_VAR_ack_services ?= $(ACK_SERVICES)
export TF_VAR_api_strategy ?= $(API_STRATEGY)
export TF_VAR_argo ?= $(ARGO)
export TF_VAR_autoscaler ?= $(AUTOSCALER)
export TF_VAR_aws_access_key_id ?= $(AWS_ACCESS_KEY_ID)
export TF_VAR_aws_secret_access_key ?= $(AWS_SECRET_ACCESS_KEY)
export TF_VAR_cleanup_operator ?= $(CLEANUP_OPERATOR)
export TF_VAR_cloudflare_api_key ?= $(CLOUDFLARE_API_KEY)
export TF_VAR_cloudflare_email ?= $(CLOUDFLARE_EMAIL)
export TF_VAR_cluster_issuer ?= $(CLUSTER_ISSUER)
export TF_VAR_cluster_prefix ?= $(CLUSTER_PREFIX)
export TF_VAR_dns_zone ?= $(DNS_ZONE)
export TF_VAR_efs_csi ?= $(EFS_CSI)
export TF_VAR_external_dns ?= $(EXTERNAL_DNS)
export TF_VAR_flux ?= $(FLUX)
export TF_VAR_ingress_nginx ?= $(INGRESS_NGINX)
export TF_VAR_ingress_ports ?= $(INGRESS_PORTS)
export TF_VAR_iteration ?= $(ITERATION)
export TF_VAR_kanister ?= $(KANISTER)
export TF_VAR_karpenter ?= $(KARPENTER)
export TF_VAR_kubed ?= $(KUBED)
export TF_VAR_logging ?= $(LOGGING)
export TF_VAR_longhorn ?= $(LONGHORN)
export TF_VAR_olm ?= $(OLM)
export TF_VAR_public_api_ports ?= $(PUBLIC_API_PORTS)
export TF_VAR_public_nodes_ports ?= $(PUBLIC_NODES_PORTS)
export TF_VAR_rancher ?= $(RANCHER)
export TF_VAR_rancher_admin_password ?= $(RANCHER_ADMIN_PASSWORD)
export TF_VAR_rancher_istio ?= $(RANCHER_ISTIO)
export TF_VAR_rancher_monitoring ?= $(RANCHER_MONITORING)
export TF_VAR_region ?= $(AWS_REGION)
export TF_VAR_reloader ?= $(RELOADER)
export TF_VAR_retention_hours ?= $(RETENTION_HOURS)
export TF_VAR_tempo ?= $(TEMPO)
