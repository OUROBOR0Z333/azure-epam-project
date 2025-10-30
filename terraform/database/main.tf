# Azure Database Module (MySQL Flexible Server - Free Tier Compatible)
# Creates Azure Database for MySQL Flexible Server

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
  }
}

# Data source to get the resource group
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# Data source to get the private subnet
data "azurerm_subnet" "private" {
  name                 = var.private_subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
}

# Data source to get the virtual network
data "azurerm_virtual_network" "main" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

# MySQL Flexible Server (Free Tier Compatible)
resource "azurerm_mysql_flexible_server" "main" {
  name                = var.mysql_server_name
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login    = var.mysql_administrator_login
  administrator_password = var.mysql_administrator_password
  version                = var.mysql_version

  # Use a free tier compatible SKU for Flexible Server
  sku_name   = var.mysql_sku_name
  
  storage {
    size_gb = var.mysql_storage_gb
  }

  backup_retention_days        = var.mysql_backup_retention_days

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Module      = "database"
  }

  # Configure the delegated subnet for Flexible Server
  delegated_subnet_id = var.delegated_subnet_id
  
  # Enable private access
  private_network_access {
    subnet_id = var.delegated_subnet_id
  }
}

# MySQL Database (for Flexible Server)
resource "azurerm_mysql_flexible_database" "main" {
  name                = var.mysql_database_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

# Private DNS Zone for MySQL Flexible Server
resource "azurerm_private_dns_zone" "mysql" {
  name                = "${azurerm_mysql_flexible_server.main.name}.private.mysql.database.azure.com"
  resource_group_name = var.resource_group_name
}

# Virtual Network Link for Private DNS Zone
resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                  = "${var.mysql_server_name}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = data.azurerm_virtual_network.main.id
}

# DNS Zone Flexible Server Link
resource "azurerm_private_dns_zone_dns_record_set" "mysql_a_record" {
  name                = azurerm_mysql_flexible_server.main.name
  resource_group_name = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  ttl                 = 300
  type                = "A"
  records             = [azurerm_mysql_flexible_server.main.private_ip_address]
}

# Outputs
output "mysql_server_id" {
  description = "The ID of the MySQL server"
  value       = azurerm_mysql_flexible_server.main.id
}

output "mysql_server_name" {
  description = "The name of the MySQL server"
  value       = azurerm_mysql_flexible_server.main.name
}

output "mysql_server_fqdn" {
  description = "The FQDN of the MySQL server"
  value       = azurerm_mysql_flexible_server.main.fqdn
}

output "mysql_database_id" {
  description = "The ID of the MySQL database"
  value       = azurerm_mysql_flexible_database.main.id
}

output "mysql_database_name" {
  description = "The name of the MySQL database"
  value       = azurerm_mysql_flexible_database.main.name
}

output "private_dns_zone_id" {
  description = "The ID of the private DNS zone"
  value       = azurerm_private_dns_zone.mysql.id
}