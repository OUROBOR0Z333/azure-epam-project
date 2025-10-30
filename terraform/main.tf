# Main Terraform Configuration
# Orchestrates all infrastructure modules

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.117"  # Latest 3.x version
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Foundation Module
module "foundation" {
  source              = "./foundation"
  environment         = var.environment
  project_name        = var.project_name
  resource_group_name = var.resource_group_name
  location            = var.location
}

# Network Module
module "network" {
  source                        = "./network"
  environment                   = var.environment
  project_name                  = var.project_name
  resource_group_name           = module.foundation.resource_group_name
  location                      = var.location
  virtual_network_name          = var.virtual_network_name
  address_space                 = var.vnet_address_space
  public_subnet_name            = var.public_subnet_name
  private_subnet_name           = var.private_subnet_name
  bastion_subnet_name           = var.bastion_subnet_name
  public_subnet_address_prefix  = var.public_subnet_address_prefix
  private_subnet_address_prefix = var.private_subnet_address_prefix
  bastion_subnet_address_prefix = var.bastion_subnet_address_prefix
  ssh_access_cidr               = var.ssh_access_cidr

  depends_on = [module.foundation]
}

# Database Module
module "database" {
  source                    = "./database"
  environment               = var.environment
  project_name              = var.project_name
  resource_group_name       = module.foundation.resource_group_name
  location                  = var.location
  mysql_server_name         = var.mysql_server_name
  mysql_administrator_login = var.mysql_administrator_login
  mysql_administrator_password = var.mysql_administrator_password
  mysql_sku_name            = var.mysql_sku_name
  mysql_version             = var.mysql_version
  mysql_storage_gb          = var.mysql_storage_gb
  mysql_backup_retention_days = var.mysql_backup_retention_days
  mysql_geo_redundant_backup_enabled = var.mysql_geo_redundant_backup_enabled
  mysql_database_name       = var.mysql_database_name
  delegated_subnet_id       = module.network.database_subnet_id
  virtual_network_id        = module.network.virtual_network_id

  depends_on = [module.network]
}

# Compute Module
module "compute" {
  source              = "./compute"
  environment         = var.environment
  project_name        = var.project_name
  resource_group_name = module.foundation.resource_group_name
  location            = var.location
  vm_name_prefix      = var.vm_name_prefix
  backend_vm_size     = var.backend_vm_size
  frontend_vm_size    = var.frontend_vm_size
  frontend_instance_count = var.frontend_instance_count
  admin_username      = var.admin_username
  ssh_public_key      = var.ssh_public_key
  private_subnet_id   = module.network.private_subnet_id

  depends_on = [module.network]
}

# Load Balancer Module
module "load_balancer" {
  source                            = "./load-balancer"
  environment                       = var.environment
  project_name                      = var.project_name
  resource_group_name               = module.foundation.resource_group_name
  location                          = var.location
  app_gateway_name                  = var.app_gateway_name
  app_gateway_sku                   = var.app_gateway_sku
  app_gateway_tier                  = var.app_gateway_tier
  app_gateway_capacity              = var.app_gateway_capacity
  public_subnet_id                  = module.network.public_subnet_id
  backend_address_pool_frontend_name = var.backend_address_pool_frontend_name
  backend_address_pool_backend_name  = var.backend_address_pool_backend_name
  backend_http_settings_frontend_name = var.backend_http_settings_frontend_name
  backend_http_settings_backend_name  = var.backend_http_settings_backend_name
  frontend_port                     = var.frontend_port
  backend_port                      = var.backend_port
  backend_path_patterns             = var.backend_path_patterns

  depends_on = [module.network, module.compute]
}

# Outputs
output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.foundation.resource_group_name
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = module.network.virtual_network_name
}

output "backend_vm_private_ip" {
  description = "Private IP of the backend VM"
  value       = module.compute.backend_private_ip
}

output "application_gateway_public_ip" {
  description = "Public IP of the application gateway"
  value       = module.load_balancer.frontend_ip_address
}

output "bastion_fqdn" {
  description = "FQDN of the bastion host"
  value       = module.network.bastion_host_id
}

output "mysql_server_fqdn" {
  description = "FQDN of the MySQL server"
  value       = module.database.mysql_server_fqdn
}