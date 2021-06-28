// General Variable set
ENVIRONMENT           = "DEVELOPMENT"
COSTCENTER            = "POC"
MAINTAINER            = "https://github.com/vlnrajesh"
SOURCE                = "https://github.com/vlnrajesh/terraform"
AWS_REGION            = "us-east-2"
/*VPC Parameters */
CIDR                  = "10.1.0.0/16"
VPC_NAME              = "DEV_VPC"
PRIVATE_SUBNETS = [
  {
    name               = "dev-pvt-1a"
    cidr               = "10.1.0.0/24"
    availability_zone  = "us-east-1a"
    additional_tags    = {
      SubnetType       = "private"
    }
  },
  {
    name               = "dev-pvt-1c"
    cidr               = "10.1.1.0/24"
    availability_zone  = "us-east-1c"
    additional_tags    = {
      SubnetType       = "private"
    }
  }
]
PUBLIC_SUBNETS = [
  {
    name               = "dev-pub-1a"
    cidr               = "10.1.2.0/25"
    availability_zone  = "us-east-1a"
    additional_tags    = {
      SubnetType       = "public"
    }
  },
  {
    name               = "dev-pub-1c"
    cidr               = "10.1.2.128/25"
    availability_zone  = "us-east-1c"
    additional_tags    = {
      SubnetType       = "public"
    }
  }
]
