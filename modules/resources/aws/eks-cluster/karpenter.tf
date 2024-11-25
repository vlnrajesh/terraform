provider "aws" {
  region            = "us-east-1"
  alias             = "virginia"
}
data "aws_ecrpublic_authorization_token" "token" {
  provider          = aws.virginia
}
resource "kubernetes_namespace" "karpenter" {
  metadata {
    annotations         = {
      name              = "karpenter"
    }
    labels = {
      name              = "karpenter"
    }
    name                = "karpenter"
  }
}
resource "kubernetes_service_account" "this" {
    count = var.create_karpenter_node_group ? 1 : 0
    metadata {
      name              = "karpenter"
      namespace         = "karpenter"
      annotations       = {
        "eks.amazonaws.com/role-arn" =  aws_iam_role.worker_node[count.index].arn
      }
    }
}
resource "helm_release" "karpenter" {
  depends_on = [
    kubernetes_namespace.karpenter
  ]
  count                = var.create_karpenter_node_group ? 1 : 0
  name                 = "karpenter"
  chart                = "karpenter"
  namespace            = var.karpenter_namespace
  repository           = "oci://public.ecr.aws/karpenter"
  version              = "0.36.2"
  repository_username  = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password  = data.aws_ecrpublic_authorization_token.token.password
  create_namespace     = false
   set {
    name       = "settings.clusterName"
    value      = var.cluster_name
  }
  set {
    name       = "settings.aws.defaultRegion"
    value      = data.aws_region.current.name
  }
  set {
    name       = "serviceAccount.create"
    value      = "false"
  }
  set {
    name       = "serviceAccount.name"
    value      = "karpenter"
  }
  set {
    name       = "controller.resources.requests.cpu"
    value      = "1"
  }
  set {
    name       = "controller.resources.requests.memory"
    value      = "1Gi"
  }
  set {
    name       = "controller.resources.limits.cpu"
    value      = "1"
  }
  set {
    name       = "controller.resources.limits.memory"
    value      = "1Gi"
  }
  set {
    name       = "replicas"
    value      = var.karpenter_replicas
  }
  set {
    name  = "nodeSelector.instances/pool"
    value = "critical"
  }
  set {
    name       = "serviceMonitor.enabled"
    value      = "true"
  }
}