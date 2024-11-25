resource "aws_iam_role" "fargate_profile" {
  count                   = var.create_fargate_profile ? 1 : 0
  name                    = "${var.cluster_name}_eks-fargate"
  assume_role_policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks-fargate-pods.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  tags = {"Name" : "${var.cluster_name}_eks-fargate", "ResourceName": "fargate_profile@${local.resource_path}"}
}
resource "aws_iam_role_policy_attachment" "fargate_profile_AmazonEKSWorkerNodePolicy" {
  count                     = var.create_fargate_profile ? 1 : 0
  policy_arn                = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role                      = aws_iam_role.fargate_profile[count.index].name
}
resource "aws_iam_role_policy_attachment" "fargate_profile_AmazonEKS_CNI_Policy" {
  count                     = var.create_fargate_profile ? 1 : 0
  policy_arn                = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role                      = aws_iam_role.fargate_profile[count.index].name
}
resource "aws_ec2_tag" "update_tags" {
  for_each = { for k,v in var.private_subnets: k => v
          if var.create_fargate_profile == true
    }
  resource_id               = each.value
  key                       = "kubernetes.io/cluster/CLUSTER_NAME"
  value                     = local.cluster_name
}
module "fargate_profile" {
  for_each        = { for k,v in var.fargate_profiles: k => v
    if var.create_fargate_profile == true
  }
  source                    = "./modules/fargate-profile"
  cluster_name              = local.cluster_name
  iam_role_arn              = aws_iam_role.fargate_profile[0].arn
  subnets                   = var.private_subnets
  name                      = lookup(each.value,"profile_name")
  selectors                 = lookup(each.value,"selectors")
}