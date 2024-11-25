output "identifier_name" {
  value = var.identifier_name
}
output "security_group_id" {
  value = module.db_security_group.id
}
output "db_port" {
  value = aws_db_instance.rds.port
}
output "address" {
  value = aws_db_instance.rds.address
}
output "endpoint" {
  value = aws_db_instance.rds.endpoint
}
output "connection_string" {
  value = aws_db_instance.rds.endpoint
}
output "username" {
  value = aws_db_instance.rds.username
}
output "initial_db_name" {
  value = var.initial_db_name
}