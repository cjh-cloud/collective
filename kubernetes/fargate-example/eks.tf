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
  source                   = "terraform-aws-modules/eks/aws"
  version                  = "~> 19.0"
  cluster_name             = "eks-serverless"
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

# resource "null_resource" "coredns_patch" {
#   provisioner "local-exec" {

#     command = "sleep 60 && kubectl patch deployment coredns -n kube-system --type json -p='[{\"op\": \"remove\", \"path\": \"/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type\"}]'"
#   }
# }

# resource "kubernetes_namespace" "cert_manager" {
#   depends_on = [
#     module.eks
#   ]

#   metadata {
#     name = "cert-manager"
#   }
# }

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

resource "helm_release" "cert_manager" {
  depends_on = [
    aws_eks_addon.coredns
  ]

  name             = "cert-manager"
  chart            = "cert-manager"
  create_namespace = true
  repository       = "https://charts.jetstack.io"
  version          = "1.11.0"
  namespace        = "cert-manager" #kubernetes_namespace.cert_manager.id

  set {
    name  = "startupapicheck.timeout"
    value = "5m"
  }
  set {
    name  = "installCRDs"
    value = "true"
  }
  set {
    name  = "webhook.securePort"
    value = "10260"
  }
}

# resource "aws_eks_addon" "adot" {
#   depends_on = [
#     helm_release.cert_manager
#   ]

#   addon_name = "adot"
#   # addon_version     = "v1.8.4-eksbuild.1"
#   cluster_name      = module.eks.cluster_name
#   resolve_conflicts = "OVERWRITE"

#   service_account_role_arn = aws_iam_role.adot_service_acc.arn
# }

variable "service_account_namespace" {
  default = "fargate-container-insights" #"opentelemetry-operator-system"
}

variable "service_account_name" {
  default = "adot-collector"
}

data "aws_iam_policy_document" "adot_trust_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    condition {
      variable = "${module.eks.oidc_provider}:sub"
      test     = "StringEquals"
      values   = ["system:serviceaccount:${var.service_account_namespace}:${var.service_account_name}"]
    }
  }
}

resource "aws_iam_role" "adot_service_acc" {

  name = "${var.env_name}-adot-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = data.aws_iam_policy_document.adot_trust_policy.json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess",
    "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
  ]

  # tags = {
  #   environment = var.env_name
  # }
}

# TODO - moving to helm chart
# resource "kubernetes_service_account" "adot" {
#   metadata {
#     name      = "adot-collector"
#     namespace = var.service_account_namespace
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.adot_service_acc.arn
#     }
#   }
# }

output "adot_iam_role_arn" {
  value = aws_iam_role.adot_service_acc.arn
}

# kubectl annotate serviceaccount -n $namespace $service_account eks.amazonaws.com/role-arn=arn:aws:iam::$account_id:role/my-role

resource "kubernetes_namespace" "fargate_container_insights" {
  metadata {
    name = var.service_account_namespace #"fargate-container-insights"
  }
}

# resource "aws_iam_policy" "policy" {
#   name        = "test-policy"
#   description = "A test policy"

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "ec2:Describe*"
#       ],
#       "Effect": "Allow",
#       "Resource": "*"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy_attachment" "test-attach" {
#   role       = aws_iam_role.adot_service_acc.name
#   policy_arn = aws_iam_policy.policy.arn
# }
