# 1. AWS Base Network Module
module "aws_network" {
  source = "./modules/aws-network"

  name_prefix        = local.name_prefix
  vpc_cidr           = var.aws_vpc_cidr
  administrator_cidr = var.administrator_cidr
  azure_vnet_cidr    = var.azure_vnet_cidr
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
}

# 2. AWS Transit Gateway Hub Module
module "aws_transit" {
  source = "./modules/aws-transit"

  name_prefix                = local.name_prefix
  vpc_id                     = module.aws_network.vpc_id
  transit_subnet_ids         = [module.aws_network.transit_subnet_a_id, module.aws_network.transit_subnet_b_id]
  tgw_asn                    = var.aws_tgw_asn
  azure_vnet_cidr            = var.azure_vnet_cidr
  application_route_table_id = module.aws_network.application_route_table_id
  management_route_table_id  = module.aws_network.management_route_table_id
}

# 3. Azure Base Network Module
module "azure_network" {
  source = "./modules/azure-network"

  name_prefix        = local.name_prefix
  location           = var.azure_location
  vnet_cidr          = var.azure_vnet_cidr
  aws_vpc_cidr       = var.aws_vpc_cidr
  administrator_cidr = var.administrator_cidr
  common_tags        = local.common_tags
}

# 4. Azure Active-Active VPN Gateway Module
module "azure_vpn" {
  source = "./modules/azure-vpn"

  name_prefix         = local.name_prefix
  resource_group_name = module.azure_network.resource_group_name
  location            = module.azure_network.resource_group_location
  gateway_subnet_id   = module.azure_network.gateway_subnet_id
  azure_vpn_asn       = var.azure_vpn_asn
  common_tags         = local.common_tags
}

# 5. Inter-Cloud IPsec VPN Module (AWS TGW <-> Azure VNG)
module "aws_vpn" {
  source = "./modules/aws-vpn"

  name_prefix               = local.name_prefix
  aws_transit_gateway_id    = module.aws_transit.transit_gateway_id
  tgw_route_table_id        = module.aws_transit.transit_gateway_route_table_id
  azure_vpn_public_ip_1     = module.azure_vpn.public_ip_1
  azure_vpn_public_ip_2     = module.azure_vpn.public_ip_2
  azure_vpn_asn             = var.azure_vpn_asn
  aws_tgw_asn               = var.aws_tgw_asn
  vpn_shared_key_1          = var.vpn_shared_key_1
  vpn_shared_key_2          = var.vpn_shared_key_2
  azure_resource_group_name = module.azure_network.resource_group_name
  azure_location            = module.azure_network.resource_group_location
  azure_vpn_gateway_id      = module.azure_vpn.vpn_gateway_id
  common_tags               = local.common_tags
}

# 6. Workload Tiers Module (AWS 3-Tier + Azure Service Node)
module "workload" {
  source = "./modules/workload"

  name_prefix                    = local.name_prefix
  aws_region                     = var.aws_region
  ami_id                         = data.aws_ami.ubuntu.id
  aws_instance_type              = var.aws_instance_type
  public_subnet_a_id             = module.aws_network.public_subnet_a_id
  public_subnet_b_id             = module.aws_network.public_subnet_b_id
  web_subnet_id                  = module.aws_network.web_subnet_a_id
  app_subnet_id                  = module.aws_network.app_subnet_a_id
  db_subnet_id                   = module.aws_network.db_subnet_a_id
  alb_security_group_id          = module.aws_network.alb_security_group_id
  web_security_group_id          = module.aws_network.web_security_group_id
  application_security_group_id  = module.aws_network.application_security_group_id
  database_security_group_id     = module.aws_network.database_security_group_id
  azure_resource_group_name      = module.azure_network.resource_group_name
  azure_location                 = module.azure_network.resource_group_location
  azure_service_subnet_id        = module.azure_network.service_subnet_id
  azure_vm_size                  = var.azure_vm_size
  database_name                  = var.database_name
  database_username              = var.database_username
  database_password              = var.database_password
  common_tags                    = local.common_tags
}

# 7. Multi-Cloud Identity Governance Module
module "identity" {
  source = "./modules/identity"

  azure_resource_group_name = module.azure_network.resource_group_name
  azure_resource_group_id   = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${module.azure_network.resource_group_name}"
}

# 8. Observability & Logging Module
module "monitoring" {
  source = "./modules/monitoring"

  name_prefix               = local.name_prefix
  vpc_id                    = module.aws_network.vpc_id
  kms_key_arn               = module.workload.kms_key_arn
  azure_resource_group_name = module.azure_network.resource_group_name
  azure_location            = module.azure_network.resource_group_location
  azure_vpn_gateway_id      = module.azure_vpn.vpn_gateway_id
  aws_vpn_connection_1_id   = module.aws_vpn.aws_vpn_connection_1_id
  enable_guardduty          = var.enable_guardduty
  enable_defender           = var.enable_defender
  common_tags               = local.common_tags
}
