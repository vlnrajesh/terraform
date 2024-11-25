resource "aws_iam_role" "this" {
  name                  = "${var.cluster_name}-ingress_controller_iam_role"
  description           = "AWS EKS load balancer ingress controller role"
  assume_role_policy    = templatefile("${path.module}/templates/iam-role-trust-policy.tftpl",
     {
       "account_id"     = local.account_id,
       "oidc_provider"  = var.oidc_provider
       "namespace"      = var.namespace,
       "service_account_name" = var.service_account_name
     }
  )
  tags                  = {"Name": "${var.cluster_name}-ingress_controller_iam_role", "ResourceName": "aws_iam_role@${local.resource_path}"}
}
resource "aws_iam_role_policy" "this" {
  name                  = "${var.cluster_name}-ingress_controller_iam_policy"
  policy                = templatefile("${path.module}/templates/iam_policy.json.tpl",
    {
      "account_id"      = local.account_id,
      "region"          = local.region
    })
  role                  = aws_iam_role.this.id

}
resource "kubernetes_service_account" "alb-ingress-controller" {
  metadata {
    name              = "alb-ingress-controller"
    namespace         = var.namespace
    annotations       = {
      "alb.ingress.kubernetes.io/ssl-min-version" = "TLSV12"
      "eks.amazonaws.com/role-arn" = aws_iam_role.this.name
    }
  }
}

resource "helm_release" "this" {
  chart             = "aws-load-balancer-controller"
  name              = "aws-load-balancer-controller"
  namespace         = var.namespace
  repository        = "https://aws.github.io/eks-charts"
  set {
    name            = "clusterName"
    value           = var.cluster_name
  }
}
resource "helm_release" "nginx-ingress" {
  chart             = "ingress-nginx"
  name              = "ingress-nginx"
  namespace         = var.namespace
  repository        = "https://kubernetes.github.io/ingress-nginx"
  set {
    name            = "controller.service.type"
    value           = "ClusterIP"
  }
}