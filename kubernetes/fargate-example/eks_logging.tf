resource "kubernetes_namespace" "fargate_logging" {
  metadata {
    name = "aws-observability"
  }
}

resource "aws_cloudwatch_log_group" "fargate_logging" {
  name_prefix       = "${var.env_name}-fargate-logging-"
  retention_in_days = 90
}

resource "kubernetes_config_map" "fargate_logging" {
  metadata {
    namespace = kubernetes_namespace.fargate_logging.metadata[0].name
    name      = "aws-logging"
  }
  data = {
    "output.conf" = templatefile("output.conf.tpl", {
      aws_region           = var.aws_region
      fargate_logging_name = aws_cloudwatch_log_group.fargate_logging.name
    })
  }
}
