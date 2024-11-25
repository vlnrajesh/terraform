data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
locals {
  account_id              = data.aws_caller_identity.current.account_id
  region                  = data.aws_region.current.name
  cleaned_relative_path   = replace(path.module,"../","")
  resource_path           = replace(local.cleaned_relative_path,"^/+","")
  parameter_prefix        = var.parameter_prefix == "" ? var.Environment: var.parameter_prefix
  helm_values             = merge(local.default_helm_values, var.settings)
  default_helm_values     = {
    "clusterName"         = var.cluster_name
    "serviceAccount.name" = var.service_account_name
    "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = aws_iam_role.this.arn
  }
}
resource "aws_iam_role" "this" {
  name                    = "${var.cluster_name}_secret-store-csi-iam_role"
  assume_role_policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${local.account_id}:oidc-provider/${var.oidc_issuer}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${var.oidc_issuer}:sub": "system:serviceaccount:${var.namespace}:${var.cluster_name}*",
          "${var.oidc_issuer}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
POLICY
  tags                    = {"Name": "${var.cluster_name}_AmazonEKS_SecretsStoreCSI_DriverRole", "ResourceName": "secret-store-csi_role@${local.resource_path}" }
}
resource "aws_iam_policy" "this" {
  name                    = "${var.cluster_name}_secret-store-csi_iam_policy"
  policy                  = jsonencode({
    "Version" : "2012-10-17",
    "Statement":[
        {
        Sid: "SSMOperations"
        Action: [
          "ssm:PutParameter",
          "ssm:Get*",
          "ssm:List*"

        ],
        Effect: "Allow",
        Resource: [
          "*"
        ]
      },
      {
        Sid: "KMSDecryption"
        Action: [
          "kms:Decrypt"
        ],
        Effect: "Allow",
        Resource: [
          "arn:aws:kms:${local.region}:${local.account_id}:alias/aws/ssm"
        ]
      },
      {
        Sid: "SecretsAccess"
        Action: [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        Effect: "Allow",
        Resource: [
          "arn:aws:ssm:${local.region}:${local.account_id}:secret:${local.parameter_prefix}/*"
        ]
      }
    ]
  })
    tags                    = {"Name": "${var.cluster_name}_efs-csi-driver_iam_policy", "ResourceName": "efs-csi-driver_iam_policy@${local.resource_path}" }

}
resource "aws_iam_role_policy_attachment" "secrets_csi_policy_attachment" {
  policy_arn = aws_iam_policy.this.arn
  role       = aws_iam_role.this.name
}
resource "helm_release" "secrets-store-csi-driver" {
  chart             = "secrets-store-csi-driver"
  name              = "secrets-store-csi-driver"
  namespace         = var.namespace
  repository        = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  set {
    name  = "clusterName"
    value = var.cluster_name
  }
  set {
    name  = "syncSecret.enabled"
    value = true
  }
  set {
    name = "enableSecretRotation"
    value = true
  }
}
resource "helm_release" "secrets-provider-aws" {
  chart             = "secrets-store-csi-driver-provider-aws"
  name              = "secrets-provider-aws"
  namespace         = var.namespace
  repository        = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  set {
    name  = "clusterName"
    value = var.cluster_name
  }
  values = [ <<-EOF
  tolerations:
    - operator: Exists
  EOF
  ]
 }