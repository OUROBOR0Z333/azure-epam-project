# Network Module
# Creates VNet, subnets, and network security groups

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
  }
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = var.virtual_network_name
  address_space       = [var.address_space]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Module      = "network"
  }
}

# Public Subnet
resource "azurerm_subnet" "public" {
  name                 = var.public_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.public_subnet_address_prefix]
}

# Private Subnet (for VMs)
resource "azurerm_subnet" "private" {
  name                 = var.private_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.private_subnet_address_prefix]
}

# Database Subnet (for MySQL Flexible Server with proper delegation)
resource "azurerm_subnet" "database" {
  name                 = "${var.private_subnet_name}-db"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.4.0/24"]

  delegation {
    name = "mysql-delegation"
    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Azure Bastion Subnet (must use this exact name)
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.bastion_subnet_address_prefix]
}

# Public Network Security Group
resource "azurerm_network_security_group" "public" {
  name                = "${var.network_security_group_prefix}-public"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.ssh_access_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Required for Application Gateway V2 - Allow health probes and management traffic
  security_rule {
    name                       = "AppGWHealthProbes"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }
}

# Private Network Security Group
resource "azurerm_network_security_group" "private" {
  name                = "${var.network_security_group_prefix}-private"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSHFromBastion"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.public_subnet_address_prefix
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AppCommunication"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.address_space
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowOutbound"
    priority                   = 1003
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSGs with subnets
resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.public.id
}

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.private.id
}

# Database subnet uses the private NSG
resource "azurerm_subnet_network_security_group_association" "database" {
  subnet_id                 = azurerm_subnet.database.id
  network_security_group_id = azurerm_network_security_group.private.id
}

# Azure Bastion
resource "azurerm_public_ip" "bastion" {
  name                = "${var.resource_group_name}-pip-bastion"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Module      = "network"
  }
}

resource "azurerm_bastion_host" "main" {
  name                = "${var.resource_group_name}-bastion"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Module      = "network"
  }
}

# Outputs
output "virtual_network_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = azurerm_subnet.public.id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = azurerm_subnet.private.id
}

output "database_subnet_id" {
  description = "The ID of the database subnet"
  value       = azurerm_subnet.database.id
}

output "bastion_host_id" {
  description = "The ID of the bastion host"
  value       = azurerm_bastion_host.main.id
}

output "public_nsg_id" {
  description = "The ID of the public network security group"
  value       = azurerm_network_security_group.public.id
}

output "private_nsg_id" {
  description = "The ID of the private network security group"
  value       = azurerm_network_security_group.private.id
}