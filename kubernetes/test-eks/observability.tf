resource "aws_prometheus_workspace" "prometheus" {
  alias = "example"

  tags = {
    Environment = var.env_name
  }
}

resource "aws_grafana_workspace" "grafana" {
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  permission_type          = "SERVICE_MANAGED"
  role_arn                 = aws_iam_role.grafana.arn
}

resource "aws_iam_role" "grafana" {
  name = "grafana-assume"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "grafana.amazonaws.com"
        }
        # "Condition": {
        #                 "StringEquals": {
        #                     "aws:SourceAccount": "410239167650"
        #                 },
        #                 "StringLike": {
        #                     "aws:SourceArn": "arn:aws:grafana:ap-southeast-2:410239167650:/workspaces/*"
        #                 }
        #             }
      },
    ]
  })
}

data "aws_iam_policy_document" "grafana_cloudwatch" {
  statement {
    sid = "AllowReadingMetricsFromCloudWatch"

    actions = [
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetInsightRuleReport"
    ]

    effect = "Allow"

    resources = ["*"]
  }

  statement {
    sid = "AllowReadingLogsFromCloudWatch"

    actions = [
      "logs:DescribeLogGroups",
      "logs:GetLogGroupFields",
      "logs:StartQuery",
      "logs:StopQuery",
      "logs:GetQueryResults",
      "logs:GetLogEvents"
    ]

    effect = "Allow"

    resources = ["*"]
  }

  statement {
    sid = "AllowReadingTagsInstancesRegionsFromEC2"

    actions = [
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions"
    ]

    effect = "Allow"

    resources = ["*"]
  }

  statement {
    sid = "AllowReadingResourcesForTags"

    actions = [
      "tag:GetResources",
    ]

    effect = "Allow"

    resources = ["*"]
  }
}

resource "aws_iam_policy" "grafana_cloudwatch" {
  name   = "GrafanaCloudWatchPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.grafana_cloudwatch.json
}

resource "aws_iam_role_policy_attachment" "grafana_cloudwatch" {
  role       = aws_iam_role.grafana.name
  policy_arn = aws_iam_policy.grafana_cloudwatch.arn
}

data "aws_iam_policy_document" "grafana_prometheus" {
  statement {
    sid = "AllowReadingMetricsFromPrometheus"

    actions = [
      "aps:ListWorkspaces",
      "aps:DescribeWorkspace",
      "aps:QueryMetrics",
      "aps:GetLabels",
      "aps:GetSeries",
      "aps:GetMetricMetadata"
    ]

    effect = "Allow"

    resources = ["*"]
  }
}

resource "aws_iam_policy" "grafana_prometheus" {
  name   = "GrafanaPrometheusPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.grafana_prometheus.json
}

resource "aws_iam_role_policy_attachment" "grafana_prometheus" {
  role       = aws_iam_role.grafana.name
  policy_arn = aws_iam_policy.grafana_prometheus.arn
}




# TODO Service/IAM roles for prometheus k8s service accounts
variable "prometheus_namespace" {
  default = "prometheus" #"fargate-container-insights" #"observability"
}

variable "service_account_amp_ingest" {
  default = "amp-iamproxy-ingest-service-account"
}

#
# Set up a trust policy designed for a specific combination of K8s service account and namespace to sign in from a Kubernetes cluster which hosts the OIDC Idp.
#
data "aws_iam_policy_document" "trust_policy_ingest" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub" # "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" #

      values = [
        "system:serviceaccount:${var.prometheus_namespace}:${var.service_account_amp_ingest}"
      ]
    }
  }
}

#
# Set up the permission policy that grants ingest (remote write) permissions for all AMP workspaces
#
data "aws_iam_policy_document" "permission_policy_ingest" {
  statement {
    actions = [
      "aps:RemoteWrite",
      "aps:GetSeries",
      "aps:GetLabels",
      "aps:GetMetricMetadata",
    ]

    effect = "Allow"

    resources = ["*"]
  }
}

resource "aws_iam_policy" "permission_policy_ingest" {
  name   = "AMPIngestPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.permission_policy_ingest.json
}

resource "aws_iam_role" "role_amp_ingest" {
  name               = "amp-iamproxy-ingest-role"
  assume_role_policy = data.aws_iam_policy_document.trust_policy_ingest.json
}

resource "aws_iam_role_policy_attachment" "permission_policy_ingest" {
  role       = aws_iam_role.role_amp_ingest.name
  policy_arn = aws_iam_policy.permission_policy_ingest.arn
}



#
# Setup a trust policy designed for a specific combination of K8s service account and namespace to sign in from a Kubernetes cluster which hosts the OIDC Idp.
#
variable "service_account_amp_query" {
  default = "amp-iamproxy-query-service-account"
}

data "aws_iam_policy_document" "trust_policy_query" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" # "${module.eks.oidc_provider}:sub"

      values = [
        "system:serviceaccount:${var.prometheus_namespace}:${var.service_account_amp_query}"
      ]
    }
  }
}

#
# Set up the permission policy that grants query permissions for all AMP workspaces
#
data "aws_iam_policy_document" "permission_policy_query" {
  statement {
    actions = [
      "aps:QueryMetrics",
      "aps:GetSeries",
      "aps:GetLabels",
      "aps:GetMetricMetadata",
    ]

    effect = "Allow"

    resources = ["*"]
  }
}

resource "aws_iam_policy" "permission_policy_query" {
  name   = "AMPQueryPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.permission_policy_query.json
}

resource "aws_iam_role" "role_amp_query" {
  name               = "amp-iamproxy-query-role"
  assume_role_policy = data.aws_iam_policy_document.trust_policy_query.json
}

resource "aws_iam_role_policy_attachment" "permission_policy_query" {
  role       = aws_iam_role.role_amp_ingest.name
  policy_arn = aws_iam_policy.permission_policy_query.arn
}


# Installing Prometheus in Helm
# helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# helm repo add kube-state-metrics https://kubernetes.github.io/kube-state-metrics # https://github.com/kubernetes/kube-state-metrics/

# helm install my-prometheus prometheus-community/prometheus --version 20.1.0
# helm upgrade --install prometheus prometheus-community/prometheus --create-namespace -n prometheus -f observability.yaml --version 20.1.0

resource "kubernetes_namespace" "prometheus" {
  depends_on = [
    module.eks
  ]

  metadata {
    name = "prometheus"
  }
}

resource "helm_release" "prometheus" {
  name             = "prometheus-community"
  chart            = "prometheus"
  create_namespace = false
  repository       = "https://prometheus-community.github.io/helm-charts"
  version          = "20.1.0"
  namespace        = kubernetes_namespace.prometheus.id

  set {
    name  = "prometheus-node-exporter.enabled"
    value = "false"
  }
  set {
    name  = "alertmanager.enabled"
    value = "false"
  }

  values = [
    jsonencode({
      prometheus-node-exporter = {
        enabled = false
      }
      alertmanager = {
        enabled = false
      }
      serviceAccounts = {
        server = {
          name = "amp-iamproxy-ingest-service-account"
          annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.role_amp_ingest.arn
          }
        }
      }
      server = {
        persistentVolume = {
          enabled = false
        }
        remoteWrite = [{
          url = "${aws_prometheus_workspace.prometheus.prometheus_endpoint}api/v1/remote_write"
          sigv4 = {
            region = var.aws_region
          }
          queue_config = {
            max_samples_per_send = 1000
            max_shards           = 200
            capacity             = 2500
          }
        }]
      }
    })
  ]

}

output "prometheus_endpoint" {
  value = aws_prometheus_workspace.prometheus.prometheus_endpoint
}

# arch -arm64 brew install awscurl
# awscurl --region ap-southeast-2  --service aps "$(tf output -raw prometheus_endpoint)api/v1/query?query=prometheus_api_remote_read_queries"

# https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-onboard-ingest-metrics-OpenTelemetry.html
# git clone https://github.com/aws-observability/aws-otel-community.git
# Sample app to test scraping prometheus metrics - in anode repo under ~/code
# docker buildx build --platform linux/amd64,linux/arm64 --push -t 410239167650.dkr.ecr.ap-southeast-2.amazonaws.com/prometheus-sample-app:latest .
# kubectl apply -f prometheus-sample-app.yaml
# awscurl --region ap-southeast-2  --service aps "$(tf output -raw prometheus_endpoint)api/v1/query?query=test_gauge0"

# TODO exists in fargate one, rename or something
resource "aws_ecr_repository" "prometheus_sample_app" {
  name                 = "prometheus-sample-app-ec2"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# push docker image to ECR
# resource "docker_registry_image" "helloworld" {
#   name          = "prometheus-sample-app:latest"
#   keep_remotely = true
# }

# Prometheus sample app k8s deployment
resource "kubernetes_deployment" "prometheus_sample_app" {
  depends_on = [
    helm_release.prometheus,
  ]

  metadata {
    name      = "prometheus-sample-app-deployment"
    namespace = "prometheus"
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "prometheus-sample-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "prometheus-sample-app"
        }
        annotations = {
          "prometheus.io/scrape" = "true"
        }
      }
      spec {
        container {
          image = "410239167650.dkr.ecr.ap-southeast-2.amazonaws.com/prometheus-sample-app:latest" #"${aws_ecr_repository.prometheus_sample_app.repository_url}:latest"
          name  = "prometheus-sample-app"

          command = ["/bin/main"]

          args = ["--metric_count=1"]

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
        }
      }
    }
  }
}

resource "kubernetes_service" "prometheus_sample_app" {
  depends_on = [
    helm_release.prometheus,
  ]

  metadata {
    name      = "prometheus-sample-app-service"
    namespace = "prometheus"
    labels = {
      app = "prometheus-sample-app"
    }
    annotations = {
      scrape = "true"
    }
  }

  spec {
    port {
      name        = "web"
      port        = 8080
      target_port = 8080
      protocol    = "TCP"
    }
    selector = {
      app = "prometheus-sample-app"
    }
  }
}


resource "kubernetes_deployment" "nodejs_app" {
  depends_on = [
    helm_release.prometheus,
  ]
  metadata {
    name      = "nodejs-app"
    namespace = "prometheus"
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "nodejs-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "nodejs-app"
        }
        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/path"   = "/metrics" # Nodejs
          "prometheus.io/port"   = "3000"     # Nodejs
        }
      }
      spec {
        container {
          image = "410239167650.dkr.ecr.ap-southeast-2.amazonaws.com/prometheus-sample-app:nestjs-metrics" #"${aws_ecr_repository.prometheus_sample_app.repository_url}:latest"
          name  = "prometheus-sample-app"

          port {
            container_port = 3000 # Nodejs
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nodejs_app" {
  depends_on = [
    helm_release.prometheus,
  ]

  metadata {
    name      = "nodejs-app-service"
    namespace = "prometheus"
    labels = {
      app = "nodejs-app"
    }
    annotations = {
      scrape = "true"
    }
  }

  spec {
    port {
      name        = "web"
      port        = 3000
      target_port = 3000
      protocol    = "TCP"
    }
    selector = {
      app = "nodejs-app"
    }
  }
}

# Load test - didn't work since it's just a default Hello World endpoint currently, but CPU did increase by 1%...
# kubectl run -n prometheus -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://nodejs-app-service:3000; done"
# kubectl get hpa -n prometheus -w
resource "kubernetes_horizontal_pod_autoscaler_v2" "nodejs_app" {
  depends_on = [
    helm_release.prometheus,
  ]

  metadata {
    name      = "nodejs-app-hpa"
    namespace = "prometheus"
  }

  spec {
    min_replicas = 1
    max_replicas = 5

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "nodejs-app"
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          average_utilization = 50
          type                = "Utilization"
        }
      }
    }

  }
}


# TODO prometheus adapter - autoscaling with hpa
# $ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# $ helm repo update
# $ helm install --name my-release prometheus-community/prometheus-adapter
# helm upgrade --install prometheus-adapter prometheus-community/prometheus-adapter -n fargate-container-insights
# https://github.com/kubernetes-sigs/prometheus-adapter

