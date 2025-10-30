# Simple Frontend Demo Configuration with Azure Bastion
# Deploys frontend VM with secure Bastion access for Ansible configuration

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.117"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-qa-tfstate"
    storage_account_name = "tfstateqa1367"
    container_name       = "tfstate"
    key                  = "simple-frontend-demo.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Variables
variable "environment" {
  description = "The environment name (e.g. demo, test)"
  type        = string
  default     = "demo"
}

variable "project_name" {
  description = "The project name"
  type        = string
  default     = "movie-analyst-demo"
}

variable "location" {
  description = "Azure region for the resources"
  type        = string
  default     = "East US"
}

variable "ssh_public_key" {
  description = "SSH public key for accessing the VM"
  type        = string
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.environment}-${var.project_name}"
  location = var.location

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "demo-frontend"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.environment}-${var.project_name}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Public Subnet (for Bastion)
resource "azurerm_subnet" "public" {
  name                 = "snet-public-${var.environment}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Private Subnet (for Frontend VM)
resource "azurerm_subnet" "private" {
  name                 = "snet-private-${var.environment}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Azure Bastion Subnet
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.3.0/24"]
}

# Network Security Group for Public Subnet
resource "azurerm_network_security_group" "public" {
  name                = "nsg-public-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Network Security Group for Private Subnet
resource "azurerm_network_security_group" "private" {
  name                = "nsg-private-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Allow SSH from Bastion subnet
  security_rule {
    name                       = "SSHFromBastion"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.3.0/24"  # Bastion subnet
    destination_address_prefix = "*"
  }

  # Allow HTTP from anywhere (for demo access)
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTPS from anywhere (for demo access)
  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Associate NSGs with Subnets
resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.public.id
}

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.private.id
}

# Public IP for Azure Bastion
resource "azurerm_public_ip" "bastion" {
  name                = "pip-bastion-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Module      = "network"
  }
}

# Azure Bastion Host
resource "azurerm_bastion_host" "main" {
  name                = "bastion-${var.environment}-${var.project_name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

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

# Network Interface for Frontend VM (no public IP)
resource "azurerm_network_interface" "frontend" {
  name                = "nic-frontend-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Frontend VM
resource "azurerm_linux_virtual_machine" "frontend" {
  name                = "vm-frontend-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1ms"  # Free Tier eligible
  admin_username      = "azureuser"
  admin_password      = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.frontend.id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Role        = "frontend-demo"
  }
}

# Outputs
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "frontend_vm_private_ip" {
  description = "Private IP address of the frontend VM"
  value       = azurerm_network_interface.frontend.private_ip_address
}

output "bastion_public_ip" {
  description = "Public IP address of the Azure Bastion"
  value       = azurerm_public_ip.bastion.ip_address
}

output "bastion_fqdn" {
  description = "FQDN of the Azure Bastion host"
  value       = azurerm_bastion_host.main.name
}