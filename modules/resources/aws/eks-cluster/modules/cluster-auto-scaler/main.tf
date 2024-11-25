data "cloudinit_config" "update_name_tag" {
  gzip                  = false
  base64_encode         = true
  part {
    filename            = "update_name_tag.sh"
    content_type        = "text/x-shellscript"
    content             = file("${path.module}/cloud_init_scripts/update_name_tag.sh")
  }
}
resource "aws_launch_template" "this" {
  name_prefix             = "${var.cluster_name}-${var.node_group_name}_"
  description             = "Launch template for ${var.node_group_name} of ${var.cluster_name}"
  update_default_version  = true
  block_device_mappings {
    device_name           = "/dev/xvda"
    ebs {
      volume_size             = var.disk_size
      volume_type             = var.volume_type
      delete_on_termination   = true
    }
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
  monitoring {
    enabled         = var.enable_monitoring
  }
  tag_specifications {
    resource_type = "instance"
    tags = merge(var.additional_tags,{
      NodeGroupName = var.node_group_name
      Environment   = var.Environment
      CreatedBy     = var.CreatedBy
    })
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      Name          = var.node_group_name
      Environment   = var.Environment
      CreatedBy     = var.CreatedBy
    }
  }
    tags = {
      Name          = var.node_group_name
      Environment   = var.Environment
      BusinessUnit  = var.BusinessUnit
      ResourceName  = "aws_launch_template@${local.resource_path}"
    }
  lifecycle {
    create_before_destroy = true
  }
  user_data = data.cloudinit_config.update_name_tag.rendered
}
resource "aws_eks_node_group" "this" {
  node_group_name_prefix   = "${var.cluster_name}-${var.node_group_name}_"
  cluster_name             = var.cluster_name
  node_role_arn            = var.node_role_arn
  subnet_ids               = var.subnets
  ami_type                 = var.ami_type
  release_version          = var.release_version
  instance_types           = local.instance_class_types[var.instance_group]
  capacity_type            = var.capacity_type
  scaling_config {
    desired_size  = var.desired_size
    max_size      = var.max_size
    min_size      = var.min_size
  }
  update_config {
    max_unavailable_percentage   = var.update_percentage
  }

  launch_template {
    name      = aws_launch_template.this.name
    version   = aws_launch_template.this.latest_version
  }
  dynamic "taint" {
    for_each =  var.taints
    content {
        key     = taint.value["key"]
        value   = taint.value["value"]
        effect  = taint.value["effect"]
    }
  }
  lifecycle {
    create_before_destroy  = true
    ignore_changes         = [scaling_config[0].desired_size]
  }
  labels                   = var.labels
  tags                     = {
    "Name"                                                = "${var.cluster_name}_${var.instance_group}"
    "k8s.io/cluster-autoscaler/enabled"                   = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}"       = "owned"
    "ResourceName"                                        = "aws_node_group@${local.resource_path}"
  }
}
