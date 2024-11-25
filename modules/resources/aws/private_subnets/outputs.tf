
output "subnet_ids" {
  value = aws_subnet.private_subnets.*.id
}
output "cidr_block" {
  value = aws_subnet.private_subnets.*.cidr_block
}
output "nat_gateway_ids" {
  value = aws_nat_gateway.nat_gateway.*.id
}