variable "shared_vpc_id" {
  description = "ID of the shared VPC"
}

variable "shared_subnet_1_id" {
  description = "ID of the first shared subnet"
}

variable "shared_subnet_2_id" {
  description = "ID of the second shared subnet"
}

variable "shared_load_balancer_arn" {
  description = "ARN of the shared load balancer"
}

variable "shared_security_group_id" {
  description = "ID of the shared security group"
}

variable "shared_ws_load_balancer_dns_name" {
  description = "DNS name of the shared load balancer"
}

variable "shared_ws_zone_id" {
  description = "Zone ID of the shared load balancer"
}

variable "shared_cert" {
  description = "ARN of the shared certificate"
}

variable "shared_ecs_cluster_id" {
  description = "ARN of the shared ECS cluster"
}

variable "shared_listener_arn" {
  description = "ARN of the shared listener"
}
