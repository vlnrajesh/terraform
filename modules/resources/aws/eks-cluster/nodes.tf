resource "aws_iam_role" "worker_node" {
  count                         = var.create_ec2_nodes ? 1 : 0
  name                          = "${var.cluster_name}-node-group"
  assume_role_policy            = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EC2TrustPolicy",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "EKSTrustPolicy",
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${local.account_id}:oidc-provider/${local.openid_connector_provider}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${local.openid_connector_provider}:sub": "system:serviceaccount:karpenter:karpenter",
          "${local.openid_connector_provider}:aud": "sts.amazonaws.com"
        }
      }
    },
    {

      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  tags                            = {"Name": "${var.cluster_name}-node-group", "DevOPS": true, "ResourceName": "worker_node@${local.resource_path}"}
}
resource "aws_iam_role_policy_attachment" "worker_node_AmazonEKSWorkerNodePolicy" {
  count                          = var.create_ec2_nodes ? 1 : 0
  policy_arn                     = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role                           = aws_iam_role.worker_node[count.index].name
}
resource "aws_iam_role_policy_attachment" "worker_node_AmazonEKS_CNI_Policy" {
  count                         = var.create_ec2_nodes ? 1 : 0
  policy_arn                    = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role                          = aws_iam_role.worker_node[count.index].name
}
resource "aws_iam_role_policy_attachment" "worker_node_AmazonSQSReadOnlyAccess" {
  count                         = var.create_ec2_nodes ? 1 : 0
  policy_arn                    = "arn:aws:iam::aws:policy/AmazonSQSReadOnlyAccess"
  role                          = aws_iam_role.worker_node[count.index].name
}
resource "aws_iam_role_policy_attachment" "worker_node_AmazonEC2ContainerRegistryReadOnly" {
  count                         = var.create_ec2_nodes ? 1 : 0
  policy_arn                    = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role                          = aws_iam_role.worker_node[count.index].name
}
resource "aws_iam_role_policy_attachment" "worker_node_AmazonSSMManagedInstanceCore" {
  count                         = var.create_ec2_nodes ? 1 : 0
  policy_arn                    = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role                          = aws_iam_role.worker_node[count.index].name
}
resource "aws_iam_role_policy_attachment" "worker_node_AmazonEBSCSIDriverPolicy" {
  count                         = var.create_ec2_nodes ? 1 : 0
  policy_arn                    = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role                          = aws_iam_role.worker_node[count.index].name
}

resource "aws_iam_policy" "cas_iam_policy" {
  count                         = var.create_ec2_nodes ? 1 : 0
  name                          = "${var.cluster_name}_NodeIAMPolicy"
  policy                        = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "acm:DescribeCertificate",
                "acm:ListCertificates",
                "acm:GetCertificate"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": aws_iam_role.worker_node[count.index].arn,
            "Sid": "PassNodeIAMRole"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags",
                "ec2:DeleteTags","ec2:DeleteSecurityGroup",
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAddresses",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeTags",
                "ec2:DescribeVpcs",
                "ec2:ModifyInstanceAttribute",
                "ec2:ModifyNetworkInterfaceAttribute",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddListenerCertificates",
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:DeleteRule",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DeregisterTargets",
                "elasticloadbalancing:DescribeListenerCertificates",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:DescribeSSLPolicies",
                "elasticloadbalancing:DescribeTags",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:ModifyRule",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:RemoveListenerCertificates",
                "elasticloadbalancing:RemoveTags",
                "elasticloadbalancing:SetIpAddressType",
                "elasticloadbalancing:SetSecurityGroups",
                "elasticloadbalancing:SetSubnets",
                "elasticloadbalancing:SetWebACL"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole",
                "iam:GetServerCertificate",
                "iam:ListServerCertificates"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeScalingActivities",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeLaunchTemplateVersions",
                "ec2:DescribeImages",
                "ec2:GetInstanceTypesFromInstanceRequirements",
                "eks:DescribeNodegroup"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cognito-idp:DescribeUserPoolClient"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cognito-idp:DescribeUserPoolClient",
                "acm:ListCertificates",
                "acm:DescribeCertificate",
                "iam:ListServerCertificates",
                "iam:GetServerCertificate",
                "waf-regional:GetWebACL",
                "waf-regional:GetWebACLForResource",
                "waf-regional:AssociateWebACL",
                "waf-regional:DisassociateWebACL",
                "wafv2:GetWebACL",
                "wafv2:GetWebACLForResource",
                "wafv2:AssociateWebACL",
                "wafv2:DisassociateWebACL",
                "shield:GetSubscriptionState",
                "shield:DescribeProtection",
                "shield:CreateProtection",
                "shield:DeleteProtection"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "tag:GetResources",
                "tag:TagResources"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "waf:GetWebACL"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
              "route53:ListHostedZones",
              "route53:ListTagsForResource",
              "route53:ChangeResourceRecordSets",
              "route53:ListResourceRecordSets"
            ],
            "Resource": "*"
        },
        {
        "Effect": "Allow",
        "Action": [
          "route53:ListTagsForResource"
        ],
        "Resource": [
          "arn:aws:route53:::hostedzone/*",
          "arn:aws:route53:::change/*"
        ]
      }
    ]
  })
  tags                          = {"Name": "${var.cluster_name}_NodeIAMPolicy", "ResourceName": "cas_iam_policy@${local.resource_path}"}
}
resource "aws_iam_policy" "karpenter_iam_policy" {
  count                        = var.create_karpenter_node_group ? 1 : 0
  name                         = "${var.cluster_name}_KarpenterControllerRole_IAMPolicy"
  policy                       = jsonencode({
    "Statement": [
        {
            "Action": [
                "ssm:GetParameter",
                "ec2:DescribeImages",
                "ec2:RunInstances",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeLaunchTemplates",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeInstanceTypeOfferings",
                "ec2:DescribeAvailabilityZones",
                "ec2:DeleteLaunchTemplate",
                "ec2:CreateTags",
                "ec2:CreateLaunchTemplate",
                "ec2:CreateFleet",
                "ec2:DescribeSpotPriceHistory",
                "pricing:GetProducts",
                "pricing:DescribeServices",
                "ce:*"
            ],
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "Karpenter"
        },
        {
            "Action": "ec2:TerminateInstances",
            "Condition": {
                "StringLike": {
                    "ec2:ResourceTag/karpenter.sh/nodepool": "*"
                }
            },
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "ConditionalEC2Termination"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::${local.account_id}:role/KarpenterNodeRole-${var.cluster_name}",
            "Sid": "PassNodeIAMRole"
        },
        {
            "Effect": "Allow",
            "Action": "eks:DescribeCluster",
            "Resource": "arn:aws:eks:${local.region}:${local.account_id}:cluster/${var.cluster_name}",
            "Sid": "EKSClusterEndpointLookup"
        },
        {
            "Sid": "AllowScopedInstanceProfileCreationActions",
            "Effect": "Allow",
            "Resource": "*",
            "Action": [
            "iam:CreateInstanceProfile"
            ],
            "Condition": {
            "StringEquals": {
                "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}": "owned",
                "aws:RequestTag/topology.kubernetes.io/region": local.region
            },
            "StringLike": {
                "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass": "*"
            }
            }
        },
        {
            "Sid": "AllowScopedInstanceProfileTagActions",
            "Effect": "Allow",
            "Resource": "*",
            "Action": [
            "iam:TagInstanceProfile"
            ],
            "Condition": {
            "StringEquals": {
                "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}": "owned",
                "aws:ResourceTag/topology.kubernetes.io/region": local.region,
                "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}": "owned",
                "aws:RequestTag/topology.kubernetes.io/region": local.region

            },
            "StringLike": {
                "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass": "*",
                "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass": "*"
            }
            }
        },
        {
            "Sid": "AllowScopedInstanceProfileActions",
            "Effect": "Allow",
            "Resource": "*",
            "Action": [
            "iam:AddRoleToInstanceProfile",
            "iam:RemoveRoleFromInstanceProfile",
            "iam:DeleteInstanceProfile"
            ],
            "Condition": {
            "StringEquals": {
                "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}": "owned",
                "aws:ResourceTag/topology.kubernetes.io/region": local.region
            },
            "StringLike": {
                "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass": "*"
            }
            }
        },
        {
            "Sid": "AllowInstanceProfileReadActions",
            "Effect": "Allow",
            "Resource": "*",
            "Action": "iam:GetInstanceProfile"
        }
    ],
    "Version": "2012-10-17"
})
  tags                = {"Name": "${var.cluster_name}_KarpenterControllerRole_IAMPolicy", "ResourceName": "karpenter_iam_policy@${local.resource_path}"}
}
resource "aws_iam_role_policy_attachment" "cas_policy_attachment" {
  count               = var.create_ec2_nodes ? 1 : 0
  policy_arn          = aws_iam_policy.cas_iam_policy[count.index].arn
  role                = aws_iam_role.worker_node[count.index].name
}
resource "aws_iam_role_policy_attachment" "karpenter_policy_attachment" {
  count               = var.create_ec2_nodes ? 1 : 0
  policy_arn          = aws_iam_policy.karpenter_iam_policy[count.index].arn
  role                = aws_iam_role.worker_node[count.index].name
}
module "node_security_group" {
  count               = var.create_ec2_nodes ? 1 : 0
  source = "../../aws/security_group"
  security_group_name      = "${var.cluster_name}-node-sg"
  vpc_id                   = var.vpc_id
}
resource "aws_security_group_rule" "ingress_all_traffic" {
  count     = var.create_ec2_nodes ? 1 : 0
  security_group_id        = module.node_security_group[count.index].id
  from_port                = 1024
  to_port                  = 65535
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  type                     = "ingress"
}
resource "aws_security_group_rule" "master_to_node_ingress" {
  count     = var.create_ec2_nodes ? 1 : 0
  description              = "Master to node access"
  security_group_id        = module.node_security_group[count.index].id
  source_security_group_id = module.cluster_security_group.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
}
data "aws_ssm_parameter" "release_version" {
  name                      = "/aws/service/eks/optimized-ami/${var.cluster_version}/amazon-linux-2023/x86_64/standard/recommended/release_version"
}
resource "aws_ssm_parameter" "node_iam_role" {
  count                     = var.create_ec2_nodes ? 1 : 0
  name                      = "/${var.Environment}/${var.cluster_name}/node_iam_role"
  type                      = "String"
  value                     = aws_iam_role.worker_node[count.index].name
  tags                      = {"Name": "${var.cluster_name}-node_iam_role", "ResourceName": "node_iam_role@${local.resource_path}" }
}

resource "kubernetes_env" "AWS_VPC_K8S_CNI_EXTERNALSNAT" {
  count                     = var.create_ec2_nodes ? 1 : 0
  container                 = "aws-node"
  metadata {
    namespace               = "kube-system"
    name                    = "aws-node"
  }
  env {
    name                    = "AWS_VPC_K8S_CNI_EXTERNALSNAT"
    value                   = true
  }
  api_version               = "apps/v1"
  kind                      = "DaemonSet"
  force                     = true
}
module "cas_groups" {
   for_each = { for k,v in var.cas_groups: k => v
              if var.create_ec2_nodes == true
  }
  source                    = "./modules/cluster-auto-scaler"
  BusinessUnit              = var.BusinessUnit
  Environment               = var.Environment
  cluster_name              = aws_eks_cluster.this.name
  node_security_group_id    = [module.node_security_group[0].id]
  subnets                   = var.private_subnets
  node_group_name           = "${var.Environment}_${lookup(each.value,"group_name")}"
  max_size                  = lookup(each.value,"max_size",1)
  min_size                  = lookup(each.value,"min_size",1)
  desired_size              = lookup(each.value,"desired_size",1)
  disk_size                 = lookup(each.value,"disk_size",20 )
  ami_type                  = lookup(each.value,"ami_type","AL2023_x86_64_STANDARD")
  instance_group            = lookup(each.value,"instance_group")
  capacity_type             = lookup(each.value,"capacity_type","ON_DEMAND")
  update_percentage         = lookup(each.value,"update_percentage",50)
  additional_tags           = lookup(each.value,"additional_tags",{})
  taints                    = lookup(each.value,"taints",{})
  labels                    = lookup(each.value,"labels",{})
  release_version           = data.aws_ssm_parameter.release_version.value
  node_role_arn             = aws_iam_role.worker_node[0].arn
  node_role_name            = aws_iam_role.worker_node[0].name
  CreatedBy                 = var.CreatedBy
}
resource "aws_ec2_tag" "update_karpenter_tags" {
  for_each = { for k,v in var.private_subnets: k => v
    }
  resource_id = each.value
  key = "karpenter.sh/discovery"
  value = var.cluster_name
}
data "aws_security_group" "cluster-node-group-sg" {
  tags            = {
    "aws:eks:cluster-name"  = var.cluster_name
  }
}
resource "aws_ec2_tag" "cluster-node-group-sg" {
  key         = "karpenter.sh/discovery"
  resource_id = data.aws_security_group.cluster-node-group-sg.id
  value       = var.cluster_name
}
module "karpenter_pools" {
  for_each = { for k,v in var.karpenter_pools: k => v
                if var.create_karpenter_node_group == true
  }
  depends_on = [
    helm_release.karpenter
  ]
  source                    = "./modules/karpenter"
  additional_tags           = lookup(each.value,"additional_tags",{"karpenter.sh/discovery": var.cluster_name})
  cluster_name              = aws_eks_cluster.this.name
  iam_role                  = aws_iam_role.worker_node[0].name
  node_class_name           = "${var.Environment}-nodeclass"
  cpu_limit                 = lookup(each.value,"cpu_limit", 1000)
  memory_limit              = lookup(each.value,"memory_limit", 1000)
  disruption_in_hours       = lookup(each.value,"disruption_in_hours",240)
  capacity_type             = lookup(each.value,"capacity_type","spot")
  weight                    = lookup(each.value,"weight", 1)
  node_pool_name            = lookup(each.value, "node_pool_name","default")
  node_labels               = lookup(each.value,"labels", {} )
  instancePool              = lookup(each.value,"instancePool","essential")
  private_subnets           = var.private_subnets
  BusinessUnit              = var.BusinessUnit
  CreatedBy                 = var.CreatedBy
  Environment               = var.Environment
}
