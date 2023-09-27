resource "helm_release" "karpenter" {
  name             = "karpenter"
  version          = "v0.30.0"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  namespace        = "karpenter"
  create_namespace = true
  values = [<<EOF
EOF
  ]
  depends_on = [
    null_resource.wait-for-cluster
  ]
}

resource "time_sleep" "karpenter" {
  create_duration = "30s"
  depends_on = [
    helm_release.karpenter
  ]
  lifecycle {
    prevent_destroy = false
  }
}

# resource "kubectl_manifest" "karpenter-node-template" {
#   yaml_body = <<EOF
#     apiVersion: karpenter.k8s.aws/v1alpha1
#     kind: AWSNodeTemplate
#     metadata:
#       name: default
#     spec:
#       subnetSelector:
#         karpenter.sh/discovery: ${local.cluster_name}
#         Type: public
#       securityGroupSelector:
#         karpenter.sh/discovery: ${local.cluster_name}
#       instanceProfile: ${module.karpenter.karpenter.node_instance_profile_name}
#       tags:
#         ${indent(8, yamlencode(local.tags))}
#         karpenter.sh/discovery: ${local.cluster_name}
#       amiFamily: Bottlerocket
#   EOF
#   depends_on = [
#     time_sleep.karpenter
#   ]
#   lifecycle {
#     prevent_destroy = false
#   }
# }

# resource "kubectl_manifest" "karpenter-provisioner" {
#   yaml_body = <<EOF
#     apiVersion: karpenter.sh/v1alpha5
#     kind: Provisioner
#     metadata:
#       name: default
#     spec:
#       requirements:
#         - key: "karpenter.k8s.aws/instance-category"
#           operator: In
#           values: ["t", "m"]
#         - key: "karpenter.k8s.aws/instance-cpu"
#           operator: In
#           values: ["4", "8"]
#         - key: "karpenter.k8s.aws/instance-hypervisor"
#           operator: In
#           values: ["nitro"]
#         - key: "topology.kubernetes.io/zone"
#           operator: In
#           values: ${jsonencode(module.vpc.azs)}
#         - key: "kubernetes.io/arch"
#           operator: In
#           values: ["amd64"]
#         - key: "karpenter.sh/capacity-type"
#           operator: In
#           values: ["spot", "on-demand"]
#       kubeletConfiguration:
#         containerRuntime: containerd
#         maxPods: 110
#       limits:
#         resources:
#           cpu: 1000
#       consolidation:
#         enabled: true
#       providerRef:
#         name: default
#       ttlSecondsUntilExpired: 604800 # 7 * 24 * 60 * 60
#   EOF
#   depends_on = [
#     kubectl_manifest.karpenter-node-template
#   ]
#   lifecycle {
#     prevent_destroy = false
#   }
# }
