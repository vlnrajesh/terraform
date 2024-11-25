variable "addons" {
  type    = map(string)
  default = {
    "aws-ebs-csi-driver"              : "v1.32.0-eksbuild.1",
    "vpc-cni"                         : "v1.18.2-eksbuild.1",
    "kube-proxy"                      : "v1.30.0-eksbuild.3",
    "coredns"                         : "v1.11.1-eksbuild.9"
  }
}
resource "aws_eks_addon" "addons" {
  depends_on            = [
    aws_eks_cluster.this,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy
  ]
  for_each            = var.create_ec2_nodes ? var.addons: {}
  cluster_name        = var.cluster_name
  addon_name          = each.key
  addon_version       = each.value
  tags                = {"Name": each.key, "ResourcePath": "addons@${local.resource_path}"}
}
module "efs-csi-driver" {
  count               = var.efs_csi_driver ? 1 :0
  depends_on          = [aws_eks_cluster.this]
  source              = "./modules/efs-csi-driver"
  cluster_name        = aws_eks_cluster.this.name
  oidc_issuer         = local.openid_connector_provider
  aws_account_id      = local.account_id
}
module "secrets-store-csi" {
  count               = var.create_ec2_nodes ? var.secrets-store-csi ? 1 :0 : 0
  depends_on          = [aws_eks_cluster.this]
  source              = "./modules/secrets-store-csi"
  Environment         = var.Environment
  cluster_name        = var.cluster_name
  oidc_issuer         = local.openid_connector_provider
}
module "ingress-controllers" {
  count               = var.alb_ingress_controller ? 1 : 0
  source              = "./modules/ingress-controllers"
  cluster_name        = aws_eks_cluster.this.name
  oidc_provider       = local.openid_connector_provider
}

resource "kubernetes_storage_class" "gp3" {
  count               = var.create_ec2_nodes? length(lookup(var.addons, "aws-ebs-csi-driver", "")) > 1 ? 1 : 0 : 0
  storage_provisioner = "ebs.csi.aws.com"
  metadata {
    name        = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  parameters = {
    encrypted  = true
    fsType     = "ext4"
    throughput = 500
    type       = "gp3"
  }
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
}
resource "kubernetes_storage_class" "ebs-gp3" {
    count               = var.create_ec2_nodes? length(lookup(var.addons, "aws-ebs-csi-driver", "")) > 1 ? 1 : 0 : 0
    storage_provisioner = "ebs.csi.aws.com"
    metadata {
      name = "ebs-gp3"
    }
    parameters = {
      encrypted  = true
      fsType     = "ext4"
      throughput = 500
      type       = "gp3"
    }
    reclaim_policy         = "Delete"
    volume_binding_mode    = "WaitForFirstConsumer"
    allow_volume_expansion = true
}
