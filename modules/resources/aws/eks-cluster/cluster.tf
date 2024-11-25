resource "aws_iam_role" "cluster" {
  name                            = "${var.cluster_name}_cluster_role"
  assume_role_policy              = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
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
  tags                           = {"Name": "${var.cluster_name}_cluster_role", "ResourceName": "cluster_iam_role@${local.resource_path}"}
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  role                          = aws_iam_role.cluster.name
  policy_arn                    = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  role                         = aws_iam_role.cluster.name
  policy_arn                   = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_role_policy_attachment" "EKS_EFS_CSI_Driver_Policy" {
  role                        = aws_iam_role.cluster.name
  policy_arn                  = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}

module "cluster_security_group" {
  source                      = "../security_group"
  security_group_name         = "eks-${var.cluster_name}-sg"
  vpc_id                      = var.vpc_id
}
resource "aws_eks_cluster" "this" {
  depends_on                  = [
    aws_iam_role.cluster
  ]
  name                        = var.cluster_name
  role_arn                    = aws_iam_role.cluster.arn
  enabled_cluster_log_types   = ["api", "audit"]
  vpc_config {
    subnet_ids                = var.cluster_endpoint_public_access ? var.public_subnets : var.private_subnets
    security_group_ids        = [module.cluster_security_group.id]
    endpoint_public_access    = var.cluster_endpoint_public_access ? true : false
    endpoint_private_access   = var.cluster_endpoint_public_access ? false : true
  }
  version                     = var.cluster_version
  tags                        = {"Name": var.cluster_name, "ResourceName": "cluster@${local.resource_path}"}
}

resource "aws_ec2_tag" "update_private_tags" {
  for_each                    = { for k,v in var.private_subnets: k => v
          if var.alb_ingress_controller == true
    }
  resource_id                 = each.value
  key                         = "kubernetes.io/role/internal-elb"
  value                       = 1
}
resource "aws_ec2_tag" "update_cluster_name_for_private_subnets" {
  for_each = { for k,v in var.private_subnets: k => v
          if var.alb_ingress_controller == true
    }
  resource_id               = each.value
  key                       = "kubernetes.io/cluster/${var.cluster_name}"
  value                     = "shared"
}
resource "aws_ec2_tag" "update_public_tags" {
  for_each = { for k,v in var.public_subnets: k => v
          if var.alb_ingress_controller == true
    }
  resource_id               = each.value
  key                       = "kubernetes.io/role/elb"
  value                     = 1
}
resource "aws_ec2_tag" "update_cluster_name" {
  for_each = { for k,v in var.public_subnets: k => v
          if var.alb_ingress_controller == true
    }
  resource_id               = each.value
  key                       = "kubernetes.io/cluster/${var.cluster_name}"
  value                     = "shared"
}

data "tls_certificate" "cluster" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates.0.sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
}