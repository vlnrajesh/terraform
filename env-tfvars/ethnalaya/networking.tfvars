vpc_name                    = "dev"
vpc_cidr                    = "10.1.0.0/16"
dns_domain_name             = "dev.ethnalaya.local"
web_subnets            = [
  {
    name                  = "dev-web1-1a"
    cidr                  = "10.1.0.0/20"
    availability_zone     = "ap-south-1a"
    subnet_type           = "public"
  },
  {
    name                  = "dev-web1-1b"
    cidr                  = "10.1.16.0/20"
    availability_zone     = "ap-south-1b"
    subnet_type           = "public"
  }
]
app_subnets            = [
   {
    name                  = "dev-app1-1a"
    cidr                  = "10.1.32.0/20"
    availability_zone     = "ap-south-1a"
    subnet_type           = "app"
  },
  {
    name                  = "dev-app1-1b"
    cidr                  = "10.1.48.0/20"
    availability_zone     = "ap-south-1b"
    subnet_type           = "app"
   }
   ,{
    name                  = "dev-app2-1a"
    cidr                  = "10.1.64.0/20"
    availability_zone     = "ap-south-1a"
    subnet_type           = "app"
  }
  ,{
    name                  = "dev-app2-1b"
    cidr                  = "10.1.80.0/20"
    availability_zone     = "ap-south-1b"
    subnet_type           = "app"
   }
]
data_subnets            = [
   {
    name                  = "dev-data-1a"
    cidr                  = "10.1.96.0/20"
    availability_zone     = "ap-south-1a"
    subnet_type           = "data"
  },
  {
    name                  = "dev-data-1b"
    cidr                  = "10.1.112.0/20"
    availability_zone     = "ap-south-1b"
    subnet_type           = "data"
   }
]
web_nacl_rules = {
   all_tcp_inbound = {
    rule_number = 100, protocol = "tcp", from_port = 1024, to_port = 65535, action = "allow", cidr_block = "0.0.0.0/0",
    egress      = false
  }

  http_inbound = {
    rule_number = 101, protocol = "tcp", from_port = 80, to_port = 80, action = "allow", cidr_block = "0.0.0.0/0",
    egress      = false
  }
  https_inbound = {
    rule_number = 102, protocol = "tcp", from_port = 443, to_port = 443, action = "allow", cidr_block = "0.0.0.0/0",
    egress      = false
  }
  smtp_inbound = {
    rule_number = 103, protocol = "tcp", from_port = 587, to_port = 587, action = "allow", cidr_block = "0.0.0.0/0",
    egress      = false
  }
#  all_ssh_inbound = {
#    rule_number = 103, protocol = "tcp", from_port = 22, to_port = 22, action = "allow", cidr_block = "0.0.0.0/0",
#    egress      = false
#  }
  all_outbound = {
    rule_number = 200, protocol = -1, from_port = -1, to_port = -1, action = "allow", cidr_block = "0.0.0.0/0",
    egress      = true
  }
}
app_nacl_rules = {
  all_tcp_inbound = {
    rule_number = 100, protocol = "tcp", from_port = 1024, to_port = 65535, action = "allow", cidr_block = "0.0.0.0/0",
    egress      = false
  }

  http_inbound = {
    rule_number = 101, protocol = "tcp", from_port = 80, to_port = 80, action = "allow", cidr_block = "0.0.0.0/0",
    egress      = false
  }
  https_inbound = {
    rule_number = 102, protocol = "tcp", from_port = 443, to_port = 443, action = "allow", cidr_block = "0.0.0.0/0",
    egress      = false
  }
#  all_ssh_inbound = {
#    rule_number = 103, protocol = "tcp", from_port = 22, to_port = 22, action = "allow", cidr_block = "0.0.0.0/0",
#    egress      = false
#  }
  all_outbound = {
    rule_number = 200, protocol = -1, from_port = -1, to_port = -1, action = "allow", cidr_block = "0.0.0.0/0",
    egress      = true
  }
}
data_nacl_rules = {
  all_tcp_inbound = {
    rule_number = 100, protocol = "tcp", from_port = 1024, to_port = 65535, action = "allow", cidr_block = "0.0.0.0/0",
    egress      = false
  }
  all_outbound = {
    rule_number = 200, protocol = -1, from_port = -1, to_port = -1, action = "allow", cidr_block = "0.0.0.0/0",
    egress      = true
  }
}
additional_vpc_ids = []
app_static_route_table_associations = []
