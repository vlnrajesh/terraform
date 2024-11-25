resource "aws_ecr_repository" "repository_name" {
  name                    = var.repository_name
  image_tag_mutability    = var.image_tag_mutability
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete            = true
  tags                    = {"Name" : var.repository_name}
}

resource "aws_ecr_lifecycle_policy" "life_cycle_policy" {
  repository = aws_ecr_repository.repository_name.name
  policy     = jsonencode({
	rules = [
		{
          "rulePriority" = 1,
          "description"  = "Expire Images older than ${var.retention_policy.untagged} days",
          "selection" = {
            "tagStatus"     = "untagged",
            "countType"     = "sinceImagePushed",
            "countUnit"     = "days",
            "countNumber"   = var.retention_policy.untagged
			},
			"action" : {
			"type"  = "expire"
			}
		},
        {
          "rulePriority" = 2,
          "description"  = "Expire Images  overflowing ${var.retention_policy.tagged} count",
          "selection" = {
            "tagStatus"     = "tagged",
            "tagPrefixList" = ["${var.tag_prefix}_"]
            "countType"     = "imageCountMoreThan",
            "countNumber"   = var.retention_policy.tagged
			},
			"action" : {
			"type"  = "expire"
			}

        }
	]
}
)
}
