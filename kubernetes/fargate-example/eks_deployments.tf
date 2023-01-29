# # todo
# # * aws_lb_controller_deployment.tf
# # AWS LoadBalancer Controller:
# # https://aws.amazon.com/about-aws/whats-new/2020/10/introducing-aws-load-balancer-controller/
# resource "helm_release" "aws_lb_controller" {
#   chart      = "aws-load-balancer-controller"
#   name       = "aws-load-balancer-controller"
#   namespace  = var.namespace
#   repository = "https://aws.github.io/eks-charts"

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.eks_aws_load_balancer_controller.arn
#   }

#   set {
#     name  = "clusterName"
#     value = module.eks.cluster_id # var.cluster_name
#   }

#   set {
#     name  = "image.repository"
#     value = "602401143452.dkr.ecr.${var.aws_region}.amazonaws.com/amazon/aws-load-balancer-controller"
#   }

#   depends_on = [kubernetes_namespace.this]
# }

# # * aws_lb_controller_iam.tf
# # AWS-ALB-Ingress (automatically manages ingress and loadbalancers):
# resource "aws_iam_role" "eks_aws_load_balancer_controller" {
#   name               = "${var.env_name}_EKSAWSLoadbalancerController"
#   assume_role_policy = data.aws_iam_policy_document.eks_role_assume.json
# }

# data "aws_iam_policy_document" "eks_aws_load_balancer_controller" {
#   statement {
#     actions = [
#       "ec2:*",
#       "elasticloadbalancing:*",
#       "cognito-idp:DescribeUserPoolClient",
#       "acm:ListCertificates",
#       "acm:DescribeCertificate",
#       "iam:CreateServiceLinkedRole",
#       "iam:ListServerCertificates",
#       "iam:GetServerCertificate",
#       "waf-regional:GetWebACL",
#       "waf-regional:GetWebACLForResource",
#       "waf-regional:AssociateWebACL",
#       "waf-regional:DisassociateWebACL",
#       "wafv2:GetWebACL",
#       "wafv2:GetWebACLForResource",
#       "wafv2:AssociateWebACL",
#       "wafv2:DisassociateWebACL",
#       "shield:GetSubscriptionState",
#       "shield:DescribeProtection",
#       "shield:CreateProtection",
#       "shield:DeleteProtection",

#     ]
#     resources = ["*"]
#   }
# }

# resource "aws_iam_role_policy" "eks_aws_load_balancer_controller" {
#   name   = "eks-pod"
#   role   = aws_iam_role.eks_aws_load_balancer_controller.name
#   policy = data.aws_iam_policy_document.eks_aws_load_balancer_controller.json
# }

# # * external_dns_deployment.tf
# # External DNS:
# # https://github.com/kubernetes-sigs/external-dns
# resource "helm_release" "external_dns" {
#   chart      = "external-dns"
#   name       = "external-dns"
#   namespace  = var.namespace
#   repository = "https://charts.bitnami.com/bitnami"

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.eks_external_dns.arn
#   }

#   set {
#     name  = "podSecurityContext.fsGroup"
#     value = 65534
#   }

#   set {
#     name  = "podSecurityContext.runAsUser"
#     value = 0
#   }

#   depends_on = [kubernetes_namespace.this]
# }

# # * external_dns_iam.tf
# # External DNS (manages Route53 records):
# resource "aws_iam_role" "eks_external_dns" {
#   name               = "${var.env_name}_EKSExternalDNS"
#   assume_role_policy = data.aws_iam_policy_document.eks_role_assume.json
# }

# data "aws_iam_policy_document" "eks_external_dns" {
#   statement {
#     actions   = ["route53:List*"]
#     resources = ["*"]
#   }

#   statement {
#     actions   = ["route53:ChangeResourceRecordSets"]
#     resources = ["*"]
#   }
# }

# resource "aws_iam_role_policy" "eks_external_dns" {
#   name   = "eks-pod"
#   role   = aws_iam_role.eks_external_dns.name
#   policy = data.aws_iam_policy_document.eks_external_dns.json
# }

# # * iam_assume.tf
# # IAM assume-role policy for EKS pods assumption:
# data "aws_iam_policy_document" "eks_role_assume" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     principals {
#       identifiers = [module.eks.oidc_provider_arn] # [var.oidc_provider_arn]
#       type        = "Federated"
#     }
#   }
# }

# # * namespace.tf
# # Create the namespace:
# resource "kubernetes_namespace" "this" {
#   metadata {
#     name = var.namespace
#   }
# }

# * variables.tf
variable "aws_region" {
  description = "The AWS region to operate in"
  default     = "ap-southeast-2"
}

# variable "cluster_name" {
#   description = "Name of the EKS cluster"
# }

variable "env_name" {
  description = "A name for this environment (to namespace AWS resources)"
  default = "dev"
}

variable "namespace" {
  description = "Name for the namespace"
  default     = "orchestration"
}

# variable "oidc_provider_arn" {
#   description = "ARN of the EKS OIDC provider to trust"
#   type        = string
# }

# # todo
# # Orchestration deployments (loadbalancer-controller & external-dns):
# # module "eks_orchestration" {
# #   source            = "../../modules/eks/orchestration"
# #   cluster_name      = module.eks.cluster_id
# #   env_name          = module.parameters.metadata.environment
# #   oidc_provider_arn = module.eks.oidc_provider_arn
# # }