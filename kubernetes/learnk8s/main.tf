provider "aws" {
  region = "ap-southeast-2"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.10.0"
    }
    helm = {
      version = "2.5.0"
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  # load_config_file       = false
  # version                = "~> 1.11"
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name = "my-cluster"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0" # 2.47.0

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
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.24.0" # 18.21.0  12.2.0

  cluster_name    = "${local.cluster_name}"
  cluster_version = "1.22" # 1.17
  subnets      = module.vpc.private_subnets # version 17.24.0 it was just "subnets"
  vpc_id          = module.vpc.vpc_id

  node_groups = {
    first = {
      desired_capacity = 1
      max_capacity     = 10
      min_capacity     = 1

      instance_type = "t3.large" # TODO : reeee
    }
    second = {
      desired_capacity = 1
      max_capacity     = 10
      min_capacity     = 1

      instance_type = "t3.small"
    }
  }

  write_kubeconfig   = true
#   config_output_path = "./"

  workers_additional_policies = [aws_iam_policy.worker_policy.arn] # ingress controller permissions

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  # worker_groups = [
  #   {
  #     name                          = "worker-group-1"
  #     instance_type                 = "t2.small"
  #     additional_userdata           = "echo foo bar"
  #     additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
  #     asg_desired_capacity          = 2
  #   },
  #   {
  #     name                          = "worker-group-2"
  #     instance_type                 = "t2.medium"
  #     additional_userdata           = "echo foo bar"
  #     additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
  #     asg_desired_capacity          = 1
  #   },
  # ]

  # eks_managed_node_group_defaults = {
  #   ami_type       = "AL2_x86_64"
  #   instance_types = ["t3.large"]

  #   attach_cluster_primary_security_group = true
  #   # vpc_security_group_ids                = [aws_security_group.additional.id]

  #   # iam_role_additional_policies = [aws_iam_policy.worker_policy.arn] # ingress controller permissions # ! doesn't work with the module

  # }

  # eks_managed_node_groups = {
  #   # Default node group - as provided by AWS EKS
  #   # default_node_group = {

  #   # }
  #   # blue = {}
  #   green = {
  #     min_size     = 2
  #     max_size     = 10
  #     desired_size = 2

  #     instance_types = ["t3.large"]
  #     capacity_type  = "SPOT"
  #     labels = {
  #       Environment = "test"
  #       GithubRepo  = "terraform-aws-eks"
  #       GithubOrg   = "terraform-aws-modules"
  #     }

  #     # taints = {
  #     #   dedicated = {
  #     #     key    = "dedicated"
  #     #     value  = "gpuGroup"
  #     #     effect = "NO_SCHEDULE"
  #     #   }
  #     # }

  #     update_config = {
  #       max_unavailable_percentage = 50 # or set `max_unavailable`
  #     }

  #     tags = {
  #       ExtraTag = "example"
  #     }
  #   }
  # }

}

# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/18.16.0 - search "invalid for_each argument"
# resource "aws_iam_role_policy_attachment" "additional" {
#   for_each = module.eks.eks_managed_node_groups
#   # you could also do the following or any combination:
#   # for_each = merge(
#   #   module.eks.eks_managed_node_groups,
#   #   module.eks.self_managed_node_group,
#   #   module.eks.fargate_profile,
#   # )

#   #            This policy does not have to exist at the time of cluster creation. Terraform can
#   #            deduce the proper order of its creation to avoid errors during creation
#   policy_arn = aws_iam_policy.worker_policy.arn
#   role       = each.value.iam_role_name
# }

resource "aws_iam_policy" "worker_policy" {
  name        = "worker-policy"
  description = "Worker policy for the ALB Ingress"

  policy = file("iam-policy-2.json")
}

# https://learnk8s.io/terraform-eks - adding helm for this tutorial
# This is to add ingress controller through helm

provider "helm" {
  # version = "2.5.0" # 1.3.1
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    # load_config_file       = false
  }
}

resource "helm_release" "ingress" {
  name       = "ingress"
  chart      = "aws-load-balancer-controller" # "aws-alb-ingress-controller"
  repository = "https://aws.github.io/eks-charts" # "https://charts.helm.sh/incubator" "http://storage.googleapis.com/kubernetes-charts-incubator"
  version    = "1.4.1" # 1.0.2

  namespace = "kube-system"

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
}

# Kubernetes resources to create similar to deployment.yaml
# resource "kubernetes_ingress" "example_ingress" {
#   metadata {
#     name = "example-ingress"
#     annotations = {
#       "alb.ingress.kubernetes.io/scheme" = "internet-facing"
#       "kubernetes.io/ingress.class" = "alb"
#     }
#   }

#   spec {
#     backend {
#       service_name = "myapp-1"
#       service_port = 8080
#     }

#     rule {
#       http {
#         path {
#           backend {
#             service_name = "myapp-1"
#             service_port = 8080
#           }

#           path = "/app1/*"
#         }

#         path {
#           backend {
#             service_name = "myapp-2"
#             service_port = 8080
#           }

#           path = "/app2/*"
#         }
#       }
#     }

#     tls {
#       secret_name = "tls-secret"
#     }
#   }
# }

# resource "kubernetes_service_v1" "example" {
#   metadata {
#     name = "myapp-1"
#   }
#   spec {
#     selector = {
#       app = kubernetes_pod.example.metadata.0.labels.app
#     }
#     session_affinity = "ClientIP"
#     port {
#       port        = 8080
#       target_port = 80
#     }

#     type = "NodePort"
#   }
# }

# resource "kubernetes_service_v1" "example2" {
#   metadata {
#     name = "myapp-2"
#   }
#   spec {
#     selector = {
#       app = kubernetes_pod.example2.metadata.0.labels.app
#     }
#     session_affinity = "ClientIP"
#     port {
#       port        = 8080
#       target_port = 80
#     }

#     type = "NodePort"
#   }
# }

# resource "kubernetes_pod" "example" {
#   metadata {
#     name = "terraform-example"
#     labels = {
#       app = "myapp-1"
#     }
#   }

#   spec {
#     container {
#       image = "nginx:1.7.9"
#       name  = "example"

#       port {
#         container_port = 8080
#       }
#     }
#   }
# }

# resource "kubernetes_pod" "example2" {
#   metadata {
#     name = "terraform-example2"
#     labels = {
#       app = "myapp-2"
#     }
#   }

#   spec {
#     container {
#       image = "nginx:1.7.9"
#       name  = "example"

#       port {
#         container_port = 8080
#       }
#     }
#   }
# }

resource "kubernetes_service" "example" {
  metadata {
    name = "test-kubernetes"
  }
  spec {
    selector = {
      name = kubernetes_deployment.example.metadata.0.name
    }
    # session_affinity = "ClientIP"
    port {
      port        = 443 # 80
      target_port = 8080
      # protocol    = "TCP"
    }

    type = "NodePort"
  }
}

resource "kubernetes_deployment" "example" {
  metadata {
    name = "test-kubernetes"
    # labels = {
    #   app = "MyExampleApp"
    # }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        name = "test-kubernetes"
      }
    }

    template {
      metadata {
        labels = {
          name = "test-kubernetes"
        }
      }

      spec {
        container {
          image = "paulbouwer/hello-kubernetes:1.8"
          name  = "app"

          port {
            container_port = 8080
          }

          # resources {
          #   limits = {
          #     cpu    = "0.5"
          #     memory = "512Mi"
          #   }
          #   requests = {
          #     cpu    = "250m"
          #     memory = "50Mi"
          #   }
          # }

          # liveness_probe {
          #   http_get {
          #     path = "/"
          #     port = 8080

          #     http_header {
          #       name  = "X-Custom-Header"
          #       value = "Awesome"
          #     }
          #   }

          #   initial_delay_seconds = 3
          #   period_seconds        = 3
          # }
        }
      }
    }
  }
}


resource "kubernetes_ingress_v1" "example_ingress" {
  metadata {
    name = "test-kubernetes"
    annotations = {
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "kubernetes.io/ingress.class" = "alb"
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTPS\":443}, {\"HTTP\":80}]"
      # "alb.ingress.kubernetes.io/backend-protocol" =  "HTTPS"
      "alb.ingress.kubernetes.io/certificate-arn" = aws_acm_certificate.cert.arn
      #alb.ingress.kubernetes.io/ssl-policy
    }
  }

  spec {
    # backend {
    #   service_name = kubernetes_service.example.metadata.0.name
    #   service_port = 8080
    # }

    default_backend {
      service {
        name = "test-kubernetes"
        port {
          number = 443 # 80
        }
      }
    }

    rule {
      http {
        path {
          backend {
            service {
              name = kubernetes_service.example.metadata.0.name
              port {
                number = 443 # 80
              }
            }
          }

          path = "/"
        }
      }
    }

    tls {
      secret_name = "tls-secret"
    }
  }
}

# Display load balancer hostname (typically present in AWS)
output "load_balancer_hostname" {
  value = kubernetes_ingress_v1.example_ingress.status.0.load_balancer.0.ingress.0.hostname
}

# Display load balancer IP (typically present in GCP, or using Nginx ingress controller)
output "load_balancer_ip" {
  value = kubernetes_ingress_v1.example_ingress.status.0.load_balancer.0.ingress.0.ip
}

# ACM cert and ALB Listener
resource "aws_acm_certificate" "cert" {
  domain_name       = "dev.cjscloud.city"
  validation_method = "DNS"

  tags = {
    Environment = "test"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# data "aws_lb" "selected" {
#   # name = split(".", kubernetes_ingress_v1.example_ingress.status.0.load_balancer.0.ingress.0.hostname)[0]
#   name = substr(kubernetes_ingress_v1.example_ingress.status.0.load_balancer.0.ingress.0.hostname, 0, 31)
# }

# output "name" {
#   value = substr(kubernetes_ingress_v1.example_ingress.status.0.load_balancer.0.ingress.0.hostname, 0, 31)
# }

# data "aws_lb_listener" "selected443" {
#   load_balancer_arn = data.aws_lb.selected.arn
#   port              = 443
# }

# resource "aws_lb_listener_certificate" "example" {
#   listener_arn    = data.aws_lb_listener.selected443.arn
#   certificate_arn = aws_acm_certificate.cert.arn
# }