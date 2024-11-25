output "subnet_ids" {
  value       = aws_subnet.public_subnets.*.id
}
