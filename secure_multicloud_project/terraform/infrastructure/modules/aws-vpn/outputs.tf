output "aws_vpn_connection_1_id" {
  value = aws_vpn_connection.azure_1.id
}

output "aws_vpn_connection_2_id" {
  value = aws_vpn_connection.azure_2.id
}

output "azure_connection_1_name" {
  value = azurerm_virtual_network_gateway_connection.aws_1.name
}

output "azure_connection_2_name" {
  value = azurerm_virtual_network_gateway_connection.aws_2.name
}
