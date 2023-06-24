# variable "service_account_namespace" {
#   default = "default" # "opentelemetry-operator-system"  #"opentelemetry-operator-system"
# }

# variable "service_account_name" {
#   default = "adot-collector"
# }

# data "aws_iam_policy_document" "adot_trust_policy" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     principals {
#       type        = "Federated"
#       identifiers = [module.eks.oidc_provider_arn]
#     }
#     condition {
#       variable = "${module.eks.oidc_provider}:sub"
#       test     = "StringEquals"
#       values   = ["system:serviceaccount:${var.service_account_namespace}:${var.service_account_name}"]
#     }
#   }
# }

# resource "aws_iam_role" "adot_service_acc" {

#   name = "${var.env_name}-adot-role"

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   assume_role_policy = data.aws_iam_policy_document.adot_trust_policy.json

#   managed_policy_arns = [
#     "arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess",
#     "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess",
#     "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
#   ]

#   # tags = {
#   #   environment = var.env_name
#   # }
# }

# output "adot_iam_role_arn" {
#   value = aws_iam_role.adot_service_acc.arn
# }

# resource "kubernetes_service_account" "adot" {
#   metadata {
#     name      = var.service_account_name
#     namespace = var.service_account_namespace
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.adot_service_acc.arn
#     }
#   }
# }

# # resource "aws_eks_addon" "adot" {
# #   depends_on = [
# #     helm_release.cert_manager
# #   ]

# #   addon_name = "adot"
# #   # addon_version     = "v1.8.4-eksbuild.1"
# #   cluster_name      = module.eks.cluster_name
# #   resolve_conflicts = "OVERWRITE"

# #   service_account_role_arn = aws_iam_role.adot_service_acc.arn
# # }
