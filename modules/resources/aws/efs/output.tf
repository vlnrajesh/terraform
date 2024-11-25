output id {
  value = aws_efs_file_system.efs.id
}
output security_group_id {
  value = module.efs_security_group.id
}
output volume_arn {
  value = aws_efs_file_system.efs.arn
}
output "efs_iam_access_policy_arn" {
  value = aws_iam_policy.resource_access_policy.arn
}
output "name" {
  value = var.efs_name
}
output "kubernetes-storage_class_name" {

  value =  local.k8s_storage_class
}
