locals {
  cleaned_relative_path   = replace(path.module,"../","")
  resource_path           = replace(local.cleaned_relative_path,"^/+","")
}
resource "aws_iam_role" "this" {
  name                    = "${var.cluster_name}_AmazonEKS_EFS_CSI_DriverRole"
  assume_role_policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${var.aws_account_id}:oidc-provider/${var.oidc_issuer}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${var.oidc_issuer}:sub": "system:serviceaccount:${var.namespace}:efs-csi-controller-sa",
          "${var.oidc_issuer}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
POLICY
  tags                = {"Name":"${var.cluster_name}_AmazonEKS_EFS_CSI_DriverRole", "ResourceName": "efs-csi-driver_iam_role@${local.resource_path}" }

}
resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn                = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role                      = aws_iam_role.this.name
}

resource "aws_eks_addon" "efs" {
  addon_name                = "aws-efs-csi-driver"
  addon_version             = var.addon_version
  cluster_name              = var.cluster_name
  service_account_role_arn  = aws_iam_role.this.arn
  tags                      = {"Name": "aws-efs-csi-driver", "ResourceName": "efs@${local.resource_path}"}
}
