output "aws_vpc_id" {
  value = module.aws_network.vpc_id
}

output "aws_transit_gateway_id" {
  value = module.aws_transit.transit_gateway_id
}

output "aws_alb_dns_name" {
  value = module.workload.aws_alb_dns_name
}

output "aws_web_private_ip" {
  value = module.workload.aws_web_private_ip
}

output "aws_app_private_ip" {
  value = module.workload.aws_app_private_ip
}

output "aws_database_private_ip" {
  value     = module.workload.aws_db_private_ip
  sensitive = true
}

output "azure_resource_group_name" {
  value = module.azure_network.resource_group_name
}

output "azure_vnet_name" {
  value = module.azure_network.vnet_name
}

output "azure_vpn_gateway_name" {
  value = module.azure_vpn.vpn_gateway_name
}

output "azure_service_private_ip" {
  value = module.workload.azure_service_private_ip
}

output "vpn_connection_summary" {
  value = {
    aws_vpn_1   = module.aws_vpn.aws_vpn_connection_1_id
    aws_vpn_2   = module.aws_vpn.aws_vpn_connection_2_id
    azure_conn_1 = module.aws_vpn.azure_connection_1_name
    azure_conn_2 = module.aws_vpn.azure_connection_2_name
  }
}
