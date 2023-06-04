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
  default = "fargate-container-insights" #"observability"
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

# helm upgrade --install prometheus prometheus-community/prometheus --create-namespace -n fargate-container-insights -f observability.yaml --version 20.1.0

# arch -arm64 brew install awscurl
# awscurl --region ap-southeast-2  --service aps "https://aps-workspaces.ap-southeast-2.amazonaws.com/workspaces/ws-4c9339c0-79b1-46fb-a150-5928fdec324d/api/v1/query?query=prometheus_api_remote_read_queries"

# https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-onboard-ingest-metrics-OpenTelemetry.html
# git clone https://github.com/aws-observability/aws-otel-community.git
# Sample app to test scraping prometheus metrics - in anode repo under ~/code
# docker buildx build --platform linux/amd64,linux/arm64 --push -t 410239167650.dkr.ecr.ap-southeast-2.amazonaws.com/prometheus-sample-app:latest .
# kubectl apply -f prometheus-sample-app.yaml
# awscurl --region ap-southeast-2  --service aps "https://aps-workspaces.ap-southeast-2.amazonaws.com/workspaces/ws-4c9339c0-79b1-46fb-a150-5928fdec324d/api/v1/query?query=test_gauge0"

resource "aws_ecr_repository" "prometheus_sample_app" {
  name                 = "prometheus-sample-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# TODO prometheus adapter - autoscaling with hpa
# $ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# $ helm repo update
# $ helm install --name my-release prometheus-community/prometheus-adapter
# helm upgrade --install prometheus-adapter prometheus-community/prometheus-adapter -n fargate-container-insights
# https://github.com/kubernetes-sigs/prometheus-adapter

