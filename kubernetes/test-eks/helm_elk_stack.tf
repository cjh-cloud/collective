# # Filebeat + ELK stack
# # https://www.youtube.com/watch?v=SU--XMhbWoY
# # helm repo add elastic https://helm.elastic.co

# # https://artifacthub.io/packages/helm/elastic/logstash
# resource "helm_release" "logstash" {
#   depends_on = [
#     module.eks
#   ]

#   name             = "logstash"
#   chart            = "elastic/logstash"
#   create_namespace = true
#   version          = "8.5.1"
#   namespace        = "elastic"

#   values = [
#     file("${path.module}/helm_elk_stack_logstash.yaml")
#   ]
# }

# # https://artifacthub.io/packages/helm/elastic/filebeat
# resource "helm_release" "filebeat" {
#   depends_on = [
#     module.eks,
#     helm_release.logstash,
#   ]

#   name             = "filebeat"
#   chart            = "elastic/filebeat"
#   create_namespace = true
#   version          = "8.5.1"
#   namespace        = "elastic"

#   set {
#     name  = "daemon.filebeatConfig.filebeat.yml"
#     value = <<-EOT
#       filebeat.inputs:
#         - type: container
#           paths:
#             - "/var/log/containers/*.log"
#           processors:
#           - add_kubernetes_metadata:
#               host: $${NODE_NAME}
#               matchers:
#               - logs_path:
#                   logs_path: "/var/log/containers/"

#         output.logstash:
#           hosts: ["logstash-logstash:5044"]
#     EOT
#   }
# }

# # https://artifacthub.io/packages/helm/elastic/elasticsearch
# resource "helm_release" "elasticsearch" {
#   depends_on = [
#     module.eks,
#     helm_release.filebeat,
#   ]

#   name             = "elasticsearch"
#   chart            = "elastic/elasticsearch"
#   create_namespace = true
#   version          = "8.5.1"
#   namespace        = "elastic"
# }

# # https://artifacthub.io/packages/helm/elastic/kibana
# resource "helm_release" "kibana" {
#   depends_on = [
#     module.eks,
#     helm_release.elasticsearch,
#   ]

#   name             = "kibana"
#   chart            = "elastic/kibana"
#   create_namespace = true
#   version          = "8.5.1"
#   namespace        = "elastic"
# }
