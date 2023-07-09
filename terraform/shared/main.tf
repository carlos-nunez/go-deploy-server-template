provider "aws" {
  region = "us-east-1"
}

# Define the ECS cluster
resource "aws_ecs_cluster" "ws_cluster" {
  name = "ws-cluster"
}

# Define the VPC
resource "aws_vpc" "ws_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "ws-vpc"
  }
}

resource "aws_route_table" "ws_public_route_table" {
  vpc_id = aws_vpc.ws_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ws_igw.id
  }
}

# Associate the public route table with the subnets
resource "aws_route_table_association" "ws_subnet_1_association" {
  subnet_id      = aws_subnet.ws_subnet_1.id
  route_table_id = aws_route_table.ws_public_route_table.id
}

resource "aws_route_table_association" "ws_subnet_2_association" {
  subnet_id      = aws_subnet.ws_subnet_2.id
  route_table_id = aws_route_table.ws_public_route_table.id
}

# Define the subnets
resource "aws_subnet" "ws_subnet_1" {
  vpc_id     = aws_vpc.ws_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "ws-subnet-1"
  }
}

resource "aws_subnet" "ws_subnet_2" {
  vpc_id     = aws_vpc.ws_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "ws-subnet-2"
  }
}

# Define the internet gateway
resource "aws_internet_gateway" "ws_igw" {
  vpc_id = aws_vpc.ws_vpc.id
  tags = {
    Name = "ws-igw"
  }
}

# Define the ALB
resource "aws_lb" "ws_load_balancer" {
  name               = "ws-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ws_security_group.id]
  subnets            = [aws_subnet.ws_subnet_1.id, aws_subnet.ws_subnet_2.id]
}

resource "aws_lb_listener" "ws_listener" {
  load_balancer_arn = aws_lb.ws_load_balancer.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy              = "ELBSecurityPolicy-2016-08"
  certificate_arn         =  aws_acm_certificate.ssl_certificate.arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: Not Found"
      status_code  = "404"
    }
  }
}

# Define the security group
resource "aws_security_group" "ws_security_group" {
  name_prefix = "ws-security-group"
  vpc_id      = aws_vpc.ws_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_acm_certificate" "ssl_certificate" {
  domain_name       = "domain.com"
  subject_alternative_names = ["*.domain.com"]

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
output "shared_vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.ws_vpc.id
}

output "shared_subnet_1_id" {
  description = "The ID of the first subnet"
  value       = aws_subnet.ws_subnet_1.id
}

output "shared_subnet_2_id" {
  description = "The ID of the second subnet"
  value       = aws_subnet.ws_subnet_2.id
}

output "shared_load_balancer_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.ws_load_balancer.arn
}

output "shared_security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.ws_security_group.id
}

output "shared_ws_load_balancer_dns_name" {
  value = aws_lb.ws_load_balancer.dns_name
}

output "shared_ws_zone_id" {
  value = aws_lb.ws_load_balancer.zone_id
}

output "shared_cert" {
  description = "ARN of the ACM certificate for domain.com"
  value       = aws_acm_certificate.ssl_certificate.arn
}

output "shared_ecs_cluster_id" {
  value = aws_ecs_cluster.ws_cluster.id
}

output "shared_listener_arn" {
  description = "The ARN of the listener"
  value       = aws_lb_listener.ws_listener.arn
}
