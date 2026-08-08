# Customer Gateways representing Azure VPN Gateway instances
resource "aws_customer_gateway" "azure_1" {
  bgp_asn    = var.azure_vpn_asn
  ip_address = var.azure_vpn_public_ip_1
  type       = "ipsec.1"

  tags = {
    Name = "${var.name_prefix}-azure-cgw-1"
  }
}

resource "aws_customer_gateway" "azure_2" {
  bgp_asn    = var.azure_vpn_asn
  ip_address = var.azure_vpn_public_ip_2
  type       = "ipsec.1"

  tags = {
    Name = "${var.name_prefix}-azure-cgw-2"
  }
}

# AWS Site-to-Site VPN Connection 1
resource "aws_vpn_connection" "azure_1" {
  customer_gateway_id = aws_customer_gateway.azure_1.id
  transit_gateway_id  = var.aws_transit_gateway_id
  type                = "ipsec.1"
  static_routes_only  = false

  tunnel1_preshared_key                  = var.vpn_shared_key_1
  tunnel1_ike_versions                   = ["ikev2"]
  tunnel1_phase1_encryption_algorithms   = ["AES256"]
  tunnel1_phase1_integrity_algorithms    = ["SHA2-256"]
  tunnel1_phase1_dh_group_numbers        = [14]
  tunnel1_phase2_encryption_algorithms   = ["AES256"]
  tunnel1_phase2_integrity_algorithms    = ["SHA2-256"]
  tunnel1_phase2_dh_group_numbers        = [14]
  tunnel1_dpd_timeout_action             = "restart"

  tags = {
    Name = "${var.name_prefix}-vpn-1"
  }
}

# AWS Site-to-Site VPN Connection 2
resource "aws_vpn_connection" "azure_2" {
  customer_gateway_id = aws_customer_gateway.azure_2.id
  transit_gateway_id  = var.aws_transit_gateway_id
  type                = "ipsec.1"
  static_routes_only  = false

  tunnel1_preshared_key                  = var.vpn_shared_key_2
  tunnel1_ike_versions                   = ["ikev2"]
  tunnel1_phase1_encryption_algorithms   = ["AES256"]
  tunnel1_phase1_integrity_algorithms    = ["SHA2-256"]
  tunnel1_phase1_dh_group_numbers        = [14]
  tunnel1_phase2_encryption_algorithms   = ["AES256"]
  tunnel1_phase2_integrity_algorithms    = ["SHA2-256"]
  tunnel1_phase2_dh_group_numbers        = [14]
  tunnel1_dpd_timeout_action             = "restart"

  tags = {
    Name = "${var.name_prefix}-vpn-2"
  }
}

# Transit Gateway Attachments Association and Propagation
resource "aws_ec2_transit_gateway_route_table_association" "vpn_1" {
  transit_gateway_attachment_id  = aws_vpn_connection.azure_1.transit_gateway_attachment_id
  transit_gateway_route_table_id = var.tgw_route_table_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpn_1" {
  transit_gateway_attachment_id  = aws_vpn_connection.azure_1.transit_gateway_attachment_id
  transit_gateway_route_table_id = var.tgw_route_table_id
}

resource "aws_ec2_transit_gateway_route_table_association" "vpn_2" {
  transit_gateway_attachment_id  = aws_vpn_connection.azure_2.transit_gateway_attachment_id
  transit_gateway_route_table_id = var.tgw_route_table_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpn_2" {
  transit_gateway_attachment_id  = aws_vpn_connection.azure_2.transit_gateway_attachment_id
  transit_gateway_route_table_id = var.tgw_route_table_id
}

# Azure Local Network Gateways representing AWS TGW Tunnel Endpoints
resource "azurerm_local_network_gateway" "aws_1" {
  name                = "lng-${var.name_prefix}-aws-1"
  location            = var.azure_location
  resource_group_name = var.azure_resource_group_name
  gateway_address     = aws_vpn_connection.azure_1.tunnel1_address

  bgp_settings {
    asn                 = var.aws_tgw_asn
    bgp_peering_address = aws_vpn_connection.azure_1.tunnel1_vgw_inside_address
  }

  tags = var.common_tags
}

resource "azurerm_local_network_gateway" "aws_2" {
  name                = "lng-${var.name_prefix}-aws-2"
  location            = var.azure_location
  resource_group_name = var.azure_resource_group_name
  gateway_address     = aws_vpn_connection.azure_2.tunnel1_address

  bgp_settings {
    asn                 = var.aws_tgw_asn
    bgp_peering_address = aws_vpn_connection.azure_2.tunnel1_vgw_inside_address
  }

  tags = var.common_tags
}

# Azure VPN Connections linking Azure VPN Gateway to AWS Local Network Gateways
resource "azurerm_virtual_network_gateway_connection" "aws_1" {
  name                       = "conn-${var.name_prefix}-aws-1"
  location                   = var.azure_location
  resource_group_name        = var.azure_resource_group_name
  type                       = "IPsec"
  virtual_network_gateway_id = var.azure_vpn_gateway_id
  local_network_gateway_id   = azurerm_local_network_gateway.aws_1.id
  shared_key                 = var.vpn_shared_key_1
  enable_bgp                 = true

  ipsec_policy {
    dh_group         = "DHGroup14"
    ike_encryption   = "AES256"
    ike_integrity    = "SHA256"
    ipsec_encryption = "AES256"
    ipsec_integrity  = "SHA256"
    pfs_group        = "PFS14"
    sa_datasize      = 102400000
    sa_lifetime      = 27000
  }

  tags = var.common_tags
}

resource "azurerm_virtual_network_gateway_connection" "aws_2" {
  name                       = "conn-${var.name_prefix}-aws-2"
  location                   = var.azure_location
  resource_group_name        = var.azure_resource_group_name
  type                       = "IPsec"
  virtual_network_gateway_id = var.azure_vpn_gateway_id
  local_network_gateway_id   = azurerm_local_network_gateway.aws_2.id
  shared_key                 = var.vpn_shared_key_2
  enable_bgp                 = true

  ipsec_policy {
    dh_group         = "DHGroup14"
    ike_encryption   = "AES256"
    ike_integrity    = "SHA256"
    ipsec_encryption = "AES256"
    ipsec_integrity  = "SHA256"
    pfs_group        = "PFS14"
    sa_datasize      = 102400000
    sa_lifetime      = 27000
  }

  tags = var.common_tags
}
