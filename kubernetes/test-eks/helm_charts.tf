# Helm charts to install

# https://artifacthub.io/packages/helm/metrics-server/metrics-server/3.9.0 - 3.10 did not work on Fargate
resource "helm_release" "metrics_server" {
  depends_on = [
    # aws_eks_addon.coredns
    module.eks
  ]

  name             = "metrics-server"
  chart            = "metrics-server"
  create_namespace = false
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  version          = "3.9.0"
  namespace        = "kube-system" #kubernetes_namespace.cert_manager.id

  set {
    name  = "apiService.create"
    value = "true"
  }
  set {
    name  = "apiService.insecureSkipTLSVerify"
    value = "true"
  }
  set {
    name  = "podLabels.k8s-app"
    value = "kube-dns"
  }
}

# resource "kubernetes_namespace" "cert_manager" {
#   depends_on = [
#     module.eks
#   ]

#   metadata {
#     name = "cert-manager"
#   }
# }

# Cert manager for ADOT if needed
resource "helm_release" "cert_manager" {
  depends_on = [
    # aws_eks_addon.coredns
    module.eks
  ]

  name             = "cert-manager"
  chart            = "cert-manager"
  create_namespace = true
  repository       = "https://charts.jetstack.io"
  version          = "1.12.0"
  namespace        = "cert-manager" #kubernetes_namespace.cert_manager.id

  set {
    name  = "startupapicheck.timeout"
    value = "5m"
  }
  set {
    name  = "installCRDs"
    value = "true"
  }
  # set {
  #   name  = "webhook.securePort"
  #   value = "10260"
  # }
}
