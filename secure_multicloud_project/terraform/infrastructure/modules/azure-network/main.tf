resource "azurerm_resource_group" "main" {
  name     = "rg-${var.name_prefix}"
  location = var.location

  tags = var.common_tags
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.name_prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [var.vnet_cidr]

  tags = var.common_tags
}

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.20.0.0/27"]
}

resource "azurerm_subnet" "service" {
  name                 = "snet-service"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.20.10.0/24"]
}

resource "azurerm_subnet" "monitoring" {
  name                 = "snet-monitoring"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.20.20.0/24"]
}

resource "azurerm_subnet" "management" {
  name                 = "snet-management"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.20.30.0/24"]
}

# Network Security Groups
resource "azurerm_network_security_group" "service" {
  name                = "nsg-${var.name_prefix}-service"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "Allow-AWS-Application-HTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "10.10.30.0/23"
    destination_address_prefix = "10.20.10.0/24"
  }

  security_rule {
    name                       = "Allow-AWS-Management-Iperf"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5201"
    source_address_prefix      = "10.10.50.0/24"
    destination_address_prefix = "10.20.10.0/24"
  }

  security_rule {
    name                       = "Deny-Other-VNet-Inbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  tags = var.common_tags
}

resource "azurerm_subnet_network_security_group_association" "service" {
  subnet_id                 = azurerm_subnet.service.id
  network_security_group_id = azurerm_network_security_group.service.id
}

resource "azurerm_network_security_group" "management" {
  name                = "nsg-${var.name_prefix}-management"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "Allow-Approved-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.administrator_cidr
    destination_address_prefix = "*"
  }

  tags = var.common_tags
}

resource "azurerm_subnet_network_security_group_association" "management" {
  subnet_id                 = azurerm_subnet.management.id
  network_security_group_id = azurerm_network_security_group.management.id
}
