module "baseline" {
  source = "../../baseline"
  api_key = ""
  uuid = "api"
  shared_vpc_id = var.shared_vpc_id
  shared_subnet_1_id = var.shared_subnet_1_id
  shared_subnet_2_id = var.shared_subnet_2_id
  shared_load_balancer_arn = var.shared_load_balancer_arn
  shared_security_group_id = var.shared_security_group_id
  shared_ws_load_balancer_dns_name = var.shared_ws_load_balancer_dns_name
  shared_ws_zone_id = var.shared_ws_zone_id
  shared_cert = var.shared_cert
  shared_ecs_cluster_id = var.shared_ecs_cluster_id
  shared_listener_arn = var.shared_listener_arn
}



# module "baseline" {
#   source = "../../baseline"
#   api_key = "28v_nqNbBnORj-rVx_sbgLsbdDNwhhYiqjVL9WD5QT4="
#   uuid = "0002"
#   shared_vpc_id = module.shared.ws_vpc_id
#   shared_subnet_1_id = module.shared.ws_subnet_1_id
#   shared_subnet_2_id = module.shared.ws_subnet_2_id
#   shared_load_balancer_arn = module.shared.ws_load_balancer_arn
#   shared_security_group_id = module.shared.ws_security_group_id
#   shared_ws_load_balancer_dns_name = module.shared.ws_load_balancer_dns_name
#   shared_ws_zone_id=module.shared.ws_load_balancer_zone_id
#   shared_ecs_cluster_id = module.shared.ws_cluster_id
#   shared_cert = "arn:aws:acm:us-east-1:492126567381:certificate/59c268ba-b965-4f8a-b9e8-c6d224909f00"
# }
