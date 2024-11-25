apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
  name: ${node_class_name}
spec:
  amiFamily: ${ami_family}
  role: ${iam_role}
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${cluster_name}
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${cluster_name}
  tags:
    karpenter.sh/discovery: ${cluster_name}
    BusinessUnit: ${BusinessUnit}
    Environment: ${Environment}
    CreatedBy: ${CreatedBy}