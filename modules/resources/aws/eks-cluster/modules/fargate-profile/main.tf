resource "aws_eks_fargate_profile" "this" {
  cluster_name           = var.cluster_name
  fargate_profile_name   = var.name
  pod_execution_role_arn = var.iam_role_arn
  subnet_ids             = var.subnets
  dynamic "selector" {
    for_each = var.selectors
    content {
      namespace = lookup(var.selectors,"namespace")
      labels    = lookup(var.selectors,"labels",{})
    }
  }
}