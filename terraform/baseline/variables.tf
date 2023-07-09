# Declare the api_key variable
variable "api_key" {
  description = "API Key to be used in the task definition"
  type        = string
}

variable "uuid" {
  description = "Unique id for the resources"
  type        = string
}

variable "shared_vpc_id" {
  description = "The ID of the shared VPC"
  type        = string
}

variable "shared_subnet_1_id" {
  description = "The ID of the first shared subnet"
  type        = string
}

variable "shared_subnet_2_id" {
  description = "The ID of the second shared subnet"
  type        = string
}

variable "shared_load_balancer_arn" {
  description = "The ARN of the shared load balancer"
  type        = string
}

variable "shared_security_group_id" {
  description = "The ID of the shared security group"
  type        = string
}

variable "shared_ws_load_balancer_dns_name" {
  description = "The dns name"
  type        = string
}

variable "shared_ws_zone_id" {
  description = "The zone id"
  type        = string
}

variable "shared_cert" {
  description = "The ssl cert"
  type        = string
}

variable "shared_ecs_cluster_id" {
  description = "The ecs cluster id"
  type        = string
}


variable "shared_listener_arn" {
  description = "The shared listsneer"
  type        = string
}


