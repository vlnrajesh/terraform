resource "helm_release" "metric-server" {
  count                 = var.create_ec2_nodes ? 1 : 0
  name                  = "metric-server"
  repository            = "https://charts.bitnami.com/bitnami"
  chart                 = "metrics-server"
  namespace             = "kube-system"
  set {
    name        = "apiService.create"
    value       = "true"
  }
}
resource "helm_release" "cluster-autoscaler" {
  count                 = var.create_ec2_nodes ? 1 :0
  name                  = "cluster-autoscaler"
  namespace             = "kube-system"
  repository            = "https://kubernetes.github.io/autoscaler"
  chart                 = "cluster-autoscaler"
  create_namespace      = false
  set {
    name    = "awsRegion"
    value   = data.aws_region.current.name
  }
  set {
    name    = "autoDiscovery.clusterName"
    value   = var.cluster_name
  }
  set {
    name    = "autoDiscovery.enabled"
    value   = "true"
  }
  set {
    name    = "serviceMonitor.enabled"
    value   = true
  }
}
data aws_ssm_parameter domain_name {
  count       = var.create_ec2_nodes ? 1 : 0
  name        = "/network/${var.Environment}/domain_name"
}
data aws_ssm_parameter zone_id {
  count       = var.create_ec2_nodes ? 1 : 0
  name        = "/network/${var.Environment}/zone_id"
}
resource "helm_release" "external_dns" {
  count       = var.create_ec2_nodes ? 1 : 0
  name        = "external-dns"
  repository  = "https://charts.bitnami.com/bitnami"
  chart       = "external-dns"
  namespace   = "kube-system"
  version     = "8.2.3"
  values      = [<<EOF
provider: "aws"
domainFilters:
  - "${data.aws_ssm_parameter.domain_name[count.index].value}"
zoneIdFilters:
  - "${data.aws_ssm_parameter.zone_id[count.index].value}"
aws:
  region: "${local.region}"
EOF
  ]
}
resource "helm_release" "keda" {
  count       = var.create_ec2_nodes ? 1 : 0
  name                = "keda"
  chart               = "keda"
  repository          = "https://kedacore.github.io/charts"
  version             = "2.15.1"
  namespace           = "keda"
  create_namespace    = true
  set {
    name    = "keda_operator_role_arn"
    value   = aws_iam_role.worker_node[count.index].arn
  }
}
resource "helm_release" "keda-add-ons-http" {
  count       = var.create_ec2_nodes ? 1 : 0
  name                = "keda-addon-http"
  chart               = "keda-add-ons-http"
  repository          = "https://kedacore.github.io/charts"
  version             = "0.8.0"
  namespace           = "keda"
  create_namespace    = true
  set {
    name    = "keda_operator_role_arn"
    value   = aws_iam_role.worker_node[count.index].arn
  }
}
