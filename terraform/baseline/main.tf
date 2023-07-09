# Define the transit gateway
resource "aws_ec2_transit_gateway" "ws_transit_gateway" {
  amazon_side_asn = 64512
  tags = {
    Name = "ws-transit-gateway-${var.uuid}"
  }
}

# Attach the internet gateway to the VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "ws_attachment" {
  subnet_ids             = [var.shared_subnet_1_id, var.shared_subnet_2_id]
  transit_gateway_id     = aws_ec2_transit_gateway.ws_transit_gateway.id
  vpc_id                 = var.shared_vpc_id
  dns_support            = "enable"
  ipv6_support           = "disable"
}

# Create secrets
data "aws_secretsmanager_secret_version" "dockerhub_creds" {
  secret_id = ""
}

# Define the task definition
resource "aws_ecs_task_definition" "ws_task_definition" {
  family                = "ws-task-${var.uuid}"
  execution_role_arn    = ""
  task_role_arn         = ""
  network_mode          = "awsvpc"
  cpu                   = "256"
  memory                = "512"
  requires_compatibilities = ["FARGATE"]

  # Import the task definition from the template file
  container_definitions = templatefile("${path.module}/server.tpl", {
    api_key               = var.api_key
    uuid                  = var.uuid
    log_group_name        = aws_cloudwatch_log_group.ws_log_group.name
  })
}

# Define the ECS service
resource "aws_ecs_service" "ws_service" {
  name            = "ws-service-${var.uuid}"
  cluster         = var.shared_ecs_cluster_id
  task_definition = aws_ecs_task_definition.ws_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets            = [var.shared_subnet_1_id, var.shared_subnet_2_id]
    assign_public_ip   = true
    security_groups    = [var.shared_security_group_id]
  }

  load_balancer {
    target_group_arn   = aws_lb_target_group.ws_tg.arn
    container_name     = "ws-container"
    container_port     = 5000
  }
}

resource "aws_cloudwatch_log_group" "ws_log_group" {
  name = "ws-log-group-${var.uuid}"
}

# Define the ALB target group
resource "aws_lb_target_group" "ws_tg" {
  name        = "ws-tg-${var.uuid}"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = var.shared_vpc_id
  target_type = "ip"

  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

# Define the ALB listener
resource "aws_lb_listener_rule" "ws_listener_rule" {
  listener_arn = var.shared_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ws_tg.arn
  }

  condition {
    host_header {
      values = ["${var.uuid}.domain.com"]
    }
  }
}

data "aws_route53_zone" "ws_zone" {
  name = "domain.com"
}

# Route 53 record
resource "aws_route53_record" "ws_subdomain" {
  zone_id = data.aws_route53_zone.ws_zone.zone_id
  name    = "${var.uuid}.socketservers.com"
  type    = "A"

  alias {
    name                   = var.shared_ws_load_balancer_dns_name
    zone_id                = var.shared_ws_zone_id
    evaluate_target_health = true
  }
}
