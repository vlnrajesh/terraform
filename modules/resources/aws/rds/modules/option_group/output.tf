output id {
  value = try(aws_db_option_group.this[0].id,null)
}