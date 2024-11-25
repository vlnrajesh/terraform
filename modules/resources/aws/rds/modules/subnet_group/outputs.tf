output id {
  value = try(aws_db_subnet_group.this[0].id,null)
}