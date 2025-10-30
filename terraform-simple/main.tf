# Simple Frontend Demo Configuration
# Deploys only a frontend VM to demonstrate the application is working

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
  description = "The environment name (e.g. qa, prod)"
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

# Subnet
resource "azurerm_subnet" "frontend" {
  name                 = "snet-frontend-${var.environment}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "frontend" {
  name                = "nsg-frontend-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

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

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "frontend" {
  subnet_id                 = azurerm_subnet.frontend.id
  network_security_group_id = azurerm_network_security_group.frontend.id
}

# Public IP for Frontend VM
resource "azurerm_public_ip" "frontend" {
  name                = "pip-frontend-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Network Interface for Frontend VM
resource "azurerm_network_interface" "frontend" {
  name                = "nic-frontend-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.frontend.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id         = azurerm_public_ip.frontend.id
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

  # Custom script extension to deploy the frontend application
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker azureuser",
      "# Here you would deploy your actual frontend application",
      "# For demo purposes, we'll just show that the VM is accessible"
    ]
  }

  connection {
    type     = "ssh"
    host     = azurerm_public_ip.frontend.ip_address
    user     = "azureuser"
    password = var.admin_password
  }
}

# Outputs
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "frontend_vm_public_ip" {
  description = "Public IP address of the frontend VM"
  value       = azurerm_public_ip.frontend.ip_address
}

output "frontend_vm_private_ip" {
  description = "Private IP address of the frontend VM"
  value       = azurerm_network_interface.frontend.private_ip_address
}

output "ssh_connection_string" {
  description = "SSH connection string to the frontend VM"
  value       = "ssh azureuser@${azurerm_public_ip.frontend.ip_address}"
}