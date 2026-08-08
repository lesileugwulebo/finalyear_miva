resource "azurerm_public_ip" "vpn_1" {
  name                = "pip-${var.name_prefix}-vpn-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]

  tags = var.common_tags
}

resource "azurerm_public_ip" "vpn_2" {
  name                = "pip-${var.name_prefix}-vpn-2"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]

  tags = var.common_tags
}

resource "azurerm_virtual_network_gateway" "main" {
  name                = "vng-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  type          = "Vpn"
  vpn_type      = "RouteBased"
  active_active = true
  enable_bgp    = true
  sku           = "VpnGw2AZ"
  generation    = "Generation2"

  ip_configuration {
    name                          = "vng-ipconfig-1"
    public_ip_address_id          = azurerm_public_ip.vpn_1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }

  ip_configuration {
    name                          = "vng-ipconfig-2"
    public_ip_address_id          = azurerm_public_ip.vpn_2.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }

  bgp_settings {
    asn = var.azure_vpn_asn
  }

  tags = var.common_tags
}
