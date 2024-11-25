create_fargate_profile    = false
efs_csi_driver            = true
cas_groups = {
  critical_apps = {
    group_name      = "critical_apps",
    instance_group  = "CPU_8C16G",
    capacity_type   = "SPOT",
    max_size        = 4,
    additional_tags = {
      "Team" : "DEVOPS",
      "BusinessUnit" : "ALL"
      "Scope" : "Hosting monitoring solutions such as Loki, prometheus and grafana and Karpenter"
      "Project" : "Monitoring"
      "Owner" : "DevOPS-Team"
    }
    labels = {
      "instances/pool" : "critical",
    }
  }
  db_apps = {
    group_name      = "db_apps",
    instance_group  = "MEM_8C64G",
    capacity_type   = "SPOT",
    max_size        = 5,
    additional_tags = {
      "Team" : "DEVOPS",
      "BusinessUnit" : "ALL"
      "Scope" : "Hosting Data layer applications"
      "Project" : "DB"
      "Owner" : "DevOPS-Team"
    }
    labels = {
      "instances/pool" : "data",
    }
    taints = [
      {
       "key" = "instances/pool",
       "value" = "data",
       "effect" = "NO_SCHEDULE"
     },
   ]
  }
}
karpenter_pools = {
  "essential" = {
    "node_pool_name"  = "essential"
    "capacity_type"   = "spot",
    "instancePool"    = "essential"
    "weight"          = 2
    "disruption_percentage" = 80
  },
  "critical" = {
    "node_pool_name"  = "critical"
    "capacity_type"   = "spot"
    "instancePool"    = "critical"
    "weight"          = 1
    "disruption_percentage" = 20
  }
}
fargate_profiles = {
  "karpenter" = {
    profile_name = "karpenter"
    selectors : { "namespace": "karpenter"}
  }
}
