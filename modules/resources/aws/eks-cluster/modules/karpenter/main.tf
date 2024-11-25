resource "kubernetes_manifest" "node_class" {
  manifest = yamldecode(templatefile("${path.module}/templates/nodeClass.yaml.tpl",{
    node_class_name      = var.node_class_name
    ami_family           = var.ami_family
    iam_role             = var.iam_role
    cluster_name         = var.cluster_name
    BusinessUnit         = var.BusinessUnit
    Environment          = var.Environment
    CreatedBy            = var.CreatedBy
  } )
  )
}
resource "kubernetes_manifest" "node_pools" {
  depends_on = [
    kubernetes_manifest.node_class
  ]
  manifest = yamldecode(templatefile("${path.module}/templates/nodePool.yaml.tpl",{
      node_pool_name      = var.node_pool_name
      instancePool        = var.instancePool
      node_class_name     = var.node_class_name
      capacity_type       = var.capacity_type
      cpu_limit           = var.cpu_limit
      memory_limit        = var.memory_limit
      disruption_in_hours = var.disruption_in_hours
      weight              = var.weight
  } ))
}