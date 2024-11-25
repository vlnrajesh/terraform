output "arn" {
  value       = aws_ecs_cluster.ecs_cluster.arn
}
output "name" {
  value       = aws_ecs_cluster.ecs_cluster.name
}
output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}
output "ecs_execution_role_name" {
  value = aws_iam_role.ecs_execution_role.name
}
output "cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.ecs_cluster_log_group.name
}