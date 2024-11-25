locals {
  name = "${var.db_identifier_name}-db-subnetgroup"
}
resource "aws_db_subnet_group" "this" {
  count             = var.create ? 1 : 0
  name              = local.name
  description       = "Database security group created for ${local.name}"
  subnet_ids        = var.subnet_ids
  tags              = {"Name" : local.name}
}