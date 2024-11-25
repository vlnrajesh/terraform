apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: ${node_pool_name}
spec:
  template:
    metadata:
      labels:
        "instances/pool": "${instancePool}"
    spec:
      nodeClassRef:
        name: ${node_class_name}
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["${capacity_type}"]
        - key: karpenter.k8s.aws/instance-size
          operator: NotIn
          values: ["nano", "micro", "small"]
        - key: karpenter.k8s.aws/instance-generation
          operator: Gt
          values: ["2"]
  limits:
    cpu: "${cpu_limit}"
    memory: "${memory_limit}Gi"
  disruption:
    consolidationPolicy: WhenUnderutilized
    expireAfter: "${disruption_in_hours}h"
  weight: "${weight}"