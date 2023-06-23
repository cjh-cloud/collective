# Define the user and role mappings for the aws-auth configmap:
locals {
  cluster_name = "eks-serverless"
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
  source                   = "terraform-aws-modules/eks/aws"
  version                  = "~> 19.0"
  cluster_name             = local.cluster_name
  cluster_version          = "1.24"
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.public_subnets
  # cluster_delete_timeout        = "30m"
  # cluster_iam_role_name     = "eks-serverless-cluster-iam-role"
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  # cluster_log_retention_in_days = 7

  vpc_id = module.vpc.vpc_id

  # fargate_pod_execution_role_name = "eks-serverless-pod-execution-role"
  // Fargate profiles here
  fargate_profiles = {
    coredns-fargate-profile = {
      name = "coredns"
      selectors = [
        {
          namespace = "kube-system"
          labels = {
            k8s-app = "kube-dns"
          }
        }
      ]
      subnets = flatten([module.vpc.private_subnets])
    },
    cert-manager-fargate-profile = {
      name = "cert-manager"
      selectors = [
        {
          namespace = "cert-manager"
        }
      ]
      subnets = flatten([module.vpc.private_subnets])
    },
    adot-fargate-profile = {
      name = "adot"
      selectors = [
        {
          namespace = var.service_account_namespace #"opentelemetry-operator-system"
        }
      ]
      subnets = flatten([module.vpc.private_subnets])
    },
    orchestration-fargate-profile = {
      name = "orchestration"
      selectors = [
        {
          namespace = "orchestration"
          labels = {
            fargate-enabled = "true"
          }
        }
      ]
      subnets = flatten([module.vpc.private_subnets])
    }
  }

  aws_auth_roles                       = local.eks_aws_auth.mapRoles
  aws_auth_users                       = local.eks_aws_auth.mapUsers
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
  enable_irsa                          = true
  manage_aws_auth_configmap            = true

  cluster_addons = {
    # coredns = {
    #   most_recent = true
    # }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

# While Fargate takes care of provisioning nodes as pods for the EKS cluster, 
# it still needs a component that can manage the networking within the cluster nodes, 
# coreDNS is that plugin for EKS Fargate, and like any other workload, needs a Fargate profile to run. 
# So we'll add both the plugin and profile configuration to our Terraform code.
resource "aws_eks_addon" "coredns" {
  addon_name = "coredns"
  # addon_version     = "v1.8.4-eksbuild.1"
  cluster_name                = module.eks.cluster_name
  resolve_conflicts_on_create = "OVERWRITE"
  depends_on                  = [module.eks]

  # provisioner "local-exec" {
  #   command = "kubectl patch deployment coredns -n kube-system --type json -p='[{\"op\": \"remove\", \"path\": \"/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type\"}]'"
  # }
}

# data "external" "oidc_thumbprint" {
#   program = [
#     "bash", "${path.module}/get-ssl-hash.sh",
#     "oidc.eks.${var.aws_region}.amazonaws.com"
#   ]
# }

# resource "aws_iam_openid_connect_provider" "default" {
#   url = "https://${module.eks.oidc_provider}" #"https://accounts.google.com"

#   client_id_list = ["sts.amazonaws.com"]

#   thumbprint_list = [replace(lower(data.external.oidc_thumbprint.result["hash"]), ":", "")]
# }

# data "aws_iam_openid_connect_provider" "oidc" {

# }
