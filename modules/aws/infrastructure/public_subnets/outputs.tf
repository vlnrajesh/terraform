output "PUBLIC_SUBNET_IDS" {
  value = aws_subnet.public_subnets.*.id
}