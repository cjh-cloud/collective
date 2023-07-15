# Define the user and role mappings for the aws-auth configmap:
locals {
  cluster_name = "my-cluster"
  eks_aws_auth = {
    mapRoles = [
      {
        rolearn  = "arn:aws:iam::410239167650:role/AWSReservedSSO_AWSAdministratorAccess_7d3695253045eea8"
        username = "admin"
        groups   = ["system:masters"]
      }
    ]
    mapUsers = [
      {
        userarn  = "arn:aws:iam::410239167650:user/connor.hewett"
        username = "admin"
        groups   = ["system:masters"]
      }
    ]
  }
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0" #"3.2.0" # 2.47.0

  name                 = "k8s-vpc"
  cidr                 = "172.16.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
  public_subnets       = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }

  tags = {
    "kubernetes.io/cluster/vpc-serverless" = "shared"
  }
}

# EKS cluster:
module "eks" {
  source                               = "terraform-aws-modules/eks/aws"
  version                              = "18.23.0" # TODO update
  aws_auth_roles                       = local.eks_aws_auth.mapRoles
  aws_auth_users                       = local.eks_aws_auth.mapUsers
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
  cluster_name                         = local.cluster_name # module.parameters.metadata.environment
  cluster_version                      = "1.27"
  enable_irsa                          = true
  manage_aws_auth_configmap            = true
  subnet_ids                           = module.vpc.private_subnets #module.parameters.subnets.private
  vpc_id                               = module.vpc.vpc_id          #module.parameters.vpc.id

  # EKS Managed Node Group(s):
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    disk_size      = 50
    instance_types = ["m5.large"]
    subnet_ids     = module.vpc.private_subnets # module.parameters.subnets.private
  }

  eks_managed_node_groups = {
    default = {
      min_size       = 1
      max_size       = 3
      desired_size   = 1
      instance_types = ["m5.large"]
      capacity_type  = "SPOT"
      labels = {
        Environment = var.env_name # module.parameters.metadata.environment
      }
    }
  }

  # Additional SG rules for nodes:
  node_security_group_additional_rules = {
    egress_all = {
      description      = "Egress (all)"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    ingress_allow_access_from_control_plane = {
      description                   = "Allow access from control plane"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }

    ingress_allow_ping_from_all_ipv4 = {
      description = "ICMP from anywhere"
      protocol    = "icmp"
      from_port   = -1
      to_port     = -1
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress_allow_ping_from_all_ipv6 = {
      description      = "ICMP from anywhere"
      protocol         = "icmpv6"
      from_port        = -1
      to_port          = -1
      type             = "ingress"
      ipv6_cidr_blocks = ["::/0"]
    }

    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }
}
