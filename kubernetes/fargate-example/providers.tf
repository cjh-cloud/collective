# AWS Provider:
provider "aws" {
  region = "ap-southeast-2"
  default_tags {
    tags = {
      Environment = "workloads"
      ManagedBy   = "Terraform"
      Owner       = "Platform"
      Stage       = "dev"
    }
  }
}

# Get the EKS cluster data (for the Kubernetes provider):
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

# Kubernetes provider:
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

# The Helm provider:
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
