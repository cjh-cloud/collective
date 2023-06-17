# Helm charts to install

# https://artifacthub.io/packages/helm/metrics-server/metrics-server/3.9.0 - 3.10 did not work on Fargate
resource "helm_release" "metrics_server" {
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
