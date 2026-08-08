output "vpn_gateway_id" {
  value = azurerm_virtual_network_gateway.main.id
}

output "vpn_gateway_name" {
  value = azurerm_virtual_network_gateway.main.name
}

output "public_ip_1" {
  value = azurerm_public_ip.vpn_1.ip_address
}

output "public_ip_2" {
  value = azurerm_public_ip.vpn_2.ip_address
}

output "bgp_peering_address_1" {
  value = azurerm_virtual_network_gateway.main.bgp_settings[0].peering_addresses[0].default_bgp_ip_addresses[0]
}

output "bgp_peering_address_2" {
  value = azurerm_virtual_network_gateway.main.bgp_settings[0].peering_addresses[1].default_bgp_ip_addresses[0]
}
