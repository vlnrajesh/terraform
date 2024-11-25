output ecr_repo_url {
  value = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${aws_ecr_repository.repository_name.name}:${var.image_tag}"
}
output "name" {
  value = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${aws_ecr_repository.repository_name.name}"
}