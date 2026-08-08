output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "resource_group_location" {
  value = azurerm_resource_group.main.location
}

output "vnet_name" {
  value = azurerm_virtual_network.main.name
}

output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "gateway_subnet_id" {
  value = azurerm_subnet.gateway.id
}

output "service_subnet_id" {
  value = azurerm_subnet.service.id
}

output "monitoring_subnet_id" {
  value = azurerm_subnet.monitoring.id
}

output "management_subnet_id" {
  value = azurerm_subnet.management.id
}

output "service_nsg_id" {
  value = azurerm_network_security_group.service.id
}
