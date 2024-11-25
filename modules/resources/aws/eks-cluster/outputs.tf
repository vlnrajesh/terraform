output "cluster_role_arn" {
  value = aws_iam_role.cluster.arn
}
output "security_group_id" {
  value = module.cluster_security_group.id
}
output "endpoint" {
  value = aws_eks_cluster.this.endpoint
}
output "cluster_name" {
  value = aws_eks_cluster.this.name
}
output "openid_connector_provider" {
  value = local.openid_connector_provider
}
output "version" {
  value = aws_eks_cluster.this.version
}
resource "aws_ssm_parameter" "oidc_provider" {
  name = "/${var.Environment}/${var.cluster_name}/oidc_provider"
  type = "String"
  value = local.openid_connector_provider
  tags  = {"Name": "${var.cluster_name}-oidc_provider"}
}

resource "aws_ssm_parameter" "cluster_name" {
  name = "/${var.Environment}/eks-cluster/name"
  type = "String"
  value = aws_eks_cluster.this.name
  tags  = {"Name": "${var.Environment}-${var.cluster_name}"}
}