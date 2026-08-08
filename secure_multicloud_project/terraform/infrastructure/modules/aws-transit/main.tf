resource "aws_ec2_transit_gateway" "main" {
  description                     = "AWS Transit Gateway Hub for Secure Multi-Cloud Interconnect"
  amazon_side_asn                 = var.tgw_asn
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = {
    Name = "${var.name_prefix}-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  subnet_ids         = var.transit_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = var.vpc_id
  dns_support        = "enable"
  ipv6_support       = "disable"

  tags = {
    Name = "${var.name_prefix}-tgw-vpc-attachment"
  }
}

resource "aws_ec2_transit_gateway_route_table" "main" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = {
    Name = "${var.name_prefix}-tgw-rt"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "vpc" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.main.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpc" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.main.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

# Subnet Routes to Azure VNet via Transit Gateway
resource "aws_route" "app_to_azure" {
  route_table_id         = var.application_route_table_id
  destination_cidr_block = var.azure_vnet_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.main.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.main]
}

resource "aws_route" "mgmt_to_azure" {
  route_table_id         = var.management_route_table_id
  destination_cidr_block = var.azure_vnet_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.main.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.main]
}
