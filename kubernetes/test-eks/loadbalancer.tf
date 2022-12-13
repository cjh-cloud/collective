resource "aws_lb" "LoadBalancer" {
  name = "${local.cluster_name}-nlb"
  internal = true
  load_balancer_type = "network"
  subnets = module.vpc.public_subnets
  enable_cross_zone_load_balancing = true
}

resource "random_id" "TargetGroupName" {
  count = length(var.container_port_mappings)
  prefix = "${local.cluster_name}-${count.index}-"
  byte_length = 2
}

resource "aws_lb_target_group" "TargetGroup" {
  count = length(var.container_port_mappings)

  name = element(random_id.TargetGroupName.*.hex, count.index)
  port = var.container_port_mappings[count.index].containerPort
  protocol = upper(var.container_port_mappings[count.index].containerProtocol)
  vpc_id = module.vpc.vpc_id
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_lb.LoadBalancer
  ]
}

resource "aws_lb_listener" "LoadBalancerListener" {
  count = length(var.container_port_mappings)

  load_balancer_arn = aws_lb.LoadBalancer.arn
  port = var.container_port_mappings[count.index].targetGroupPort
  protocol = upper(var.container_port_mappings[count.index].targetGroupProtocol)
  certificate_arn = null
  ssl_policy = null

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.TargetGroup[count.index].arn
  }

  depends_on = [
    aws_lb_target_group.TargetGroup
  ]
}

variable "container_port_mappings" {
  type = list(object({
    containerPort = number
    containerProtocol = string
    targetGroupPort = number
    targetGroupProtocol = string
  }))

  default = [{
    containerPort = 80
    containerProtocol = "tcp"
    targetGroupPort = 80
    targetGroupProtocol = "tcp"
  }]
}