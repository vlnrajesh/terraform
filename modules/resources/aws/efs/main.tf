resource "aws_efs_file_system" "efs" {
  creation_token    = var.efs_name
  encrypted         = var.encrypted
  throughput_mode   = var.throughput_mode
  performance_mode  = var.performance_mode
  tags              = {"Name" = var.efs_name}
}
locals {
  k8s_storage_class = "efs-csi-${var.efs_name}"
}
data "aws_iam_policy_document" "efs_resource_policy" {
  count = var.create_eks_storage_components ? 0 : 1
  statement {
    effect      = "Allow"
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite"
    ]
    principals {
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
      type        = "AWS"
    }
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}
resource "aws_efs_file_system_policy" this {
  count = var.create_eks_storage_components ? 0 : 1
  file_system_id    = aws_efs_file_system.efs.id
  policy            = data.aws_iam_policy_document.efs_resource_policy[count.index].json
}
resource "aws_iam_policy" "resource_access_policy" {
  name    = "${var.efs_name}_access_policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        Sid : "EFSClientWrite"
        Action : [
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientMount",

        ],
        Effect : "Allow",
        Resource : [ aws_efs_file_system.efs.arn]
      }
    ]
  })
}

module "efs_security_group" {
  source                = "../security_group/"
  security_group_name   = "${var.efs_name}-sg"
  description           = "Security group for ${var.efs_name}"
  vpc_id                = var.vpc_id
}

resource "aws_efs_mount_target" "efs_mount_target" {
  for_each = toset(var.subnets)
  file_system_id    = aws_efs_file_system.efs.id
  subnet_id         = each.value
  security_groups   = [module.efs_security_group.id]
}
resource "kubernetes_storage_class" "sc-name" {
  count = var.create_eks_storage_components ? 1 : 0
  storage_provisioner = var.storage_class_name
  metadata {
    name          = local.k8s_storage_class
  }
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId      = aws_efs_file_system.efs.id
    directoryPerms: "700"

  }
}


resource "kubernetes_persistent_volume" "tools_pv" {
   count = var.create_eks_storage_components ? 1 : 0
  metadata {
    name      = "${var.efs_name}-pv"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    capacity     = {
      storage    = "${var.storage_capacity}Gi"
    }
    persistent_volume_reclaim_policy = var.volume_reclaim_policy

    storage_class_name  = var.storage_class_name
    persistent_volume_source {
      csi {
        driver        = var.storage_class_name
        volume_handle = aws_efs_file_system.efs.id
      }
    }
  }
}