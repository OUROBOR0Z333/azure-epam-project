# Compute Module
# Creates VMs for backend and frontend services

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
  }
}

# Backend VM
resource "azurerm_network_interface" "backend" {
  name                = "${var.vm_name_prefix}-backend-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.private_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "backend" {
  name                = "${var.vm_name_prefix}-backend-vm"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.backend_vm_size
  admin_username      = var.admin_username
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.backend.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Module      = "compute"
    Role        = "backend"
  }
}

# Frontend VM Scale Set
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
    storage_account_type = "Premium_LRS"
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
    Role        = "frontend"
  }
}

# Outputs
output "backend_vm_id" {
  description = "The ID of the backend VM"
  value       = azurerm_linux_virtual_machine.backend.id
}

output "backend_vm_name" {
  description = "The name of the backend VM"
  value       = azurerm_linux_virtual_machine.backend.name
}

output "backend_private_ip" {
  description = "The private IP of the backend VM"
  value       = azurerm_network_interface.backend.private_ip_address
}

output "frontend_vmss_id" {
  description = "The ID of the frontend VM scale set"
  value       = azurerm_linux_virtual_machine_scale_set.frontend.id
}

output "frontend_vmss_name" {
  description = "The name of the frontend VM scale set"
  value       = azurerm_linux_virtual_machine_scale_set.frontend.name
}