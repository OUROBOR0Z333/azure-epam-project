# Simplified Compute Module - Frontend VM Only
# Creates only the frontend VM for the demo

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
  }
}

# Variables for the compute module
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

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the resources"
  type        = string
  default     = "East US"
}

variable "vm_name_prefix" {
  description = "Prefix for VM names"
  type        = string
  default     = "vm-movie-analyst"
}

variable "frontend_vm_size" {
  description = "Size of the frontend VM"
  type        = string
  default     = "Standard_B1ms"  # Free Tier eligible
}

variable "frontend_instance_count" {
  description = "Number of instances in the frontend VM scale set"
  type        = number
  default     = 1
}

variable "admin_username" {
  description = "Admin username for the VMs"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for accessing the VMs"
  type        = string
}

variable "private_subnet_id" {
  description = "ID of the private subnet"
  type        = string
}

# Frontend VM Scale Set (Single Instance for Demo)
resource "azurerm_linux_virtual_machine_scale_set" "frontend" {
  name                = "${var.vm_name_prefix}-frontend-vmss"
  location            = var.location
  resource_group_name = var.resource_group_name
  upgrade_mode        = "Automatic"
  admin_username      = var.admin_username
  disable_password_authentication = true

  sku = var.frontend_vm_size
  instances = var.frontend_instance_count

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

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

  network_interface {
    name    = "frontend-nic"
    primary = true

    ip_configuration {
      name      = "frontend-ip-config"
      primary   = true
      subnet_id = var.private_subnet_id
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Module      = "compute"
    Role        = "frontend-demo"
  }
}

# Outputs
output "frontend_vmss_id" {
  description = "The ID of the frontend VM scale set"
  value       = azurerm_linux_virtual_machine_scale_set.frontend.id
}

output "frontend_vmss_name" {
  description = "The name of the frontend VM scale set"
  value       = azurerm_linux_virtual_machine_scale_set.frontend.name
}

output "frontend_private_ip" {
  description = "The private IP of the frontend VM"
  value       = azurerm_linux_virtual_machine_scale_set.frontend.network_interface[0].ip_configuration[0].private_ip_address
}