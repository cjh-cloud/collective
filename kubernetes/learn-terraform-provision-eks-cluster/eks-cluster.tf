module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.small"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      asg_desired_capacity          = 2
    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t2.medium"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 1
    },
  ]

  workers_additional_policies = [aws_iam_policy.worker_policy.arn] # ingress controller permissions
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

# https://learnk8s.io/terraform-eks - tutorial - permissions required for ingress controller
resource "aws_iam_policy" "worker_policy" {
  name        = "worker-policy"
  description = "Worker policy for the ALB Ingress"

  policy = file("iam-policy.json")
}

# https://learnk8s.io/terraform-eks - adding helm for this tutorial
# This is to add ingress controller through helm

provider "helm" {
  version = "2.5.0" # 1.3.1
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    # load_config_file       = false
  }
}

resource "helm_release" "ingress" {
  name       = "ingress"
  # chart      = "aws-alb-ingress-controller"
  # repository = "https://charts.helm.sh/incubator" # "http://storage.googleapis.com/kubernetes-charts-incubator"
  # version    = "1.0.2"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  version    = "2.4.1"

  set {
    name  = "autoDiscoverAwsRegion"
    value = "true"
  }
  set {
    name  = "autoDiscoverAwsVpcID"
    value = "true"
  }
  set {
    name  = "clusterName"
    value = local.cluster_name
  }
  # set {
  #   name  = "serviceAccount.create"
  #   value = "false"
  # }
  # set {
  #   name  = "serviceAccount.name"
  #   value = "aws-load-balancer-controller"
  # }
}

# --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller