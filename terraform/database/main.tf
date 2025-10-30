# Database Module
# Creates Azure Database for MySQL

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# MySQL Flexible Server
resource "azurerm_mysql_flexible_server" "main" {
  name                   = var.mysql_server_name
  location               = var.location
  resource_group_name    = var.resource_group_name
  version                = var.mysql_version
  administrator_login    = var.mysql_administrator_login
  administrator_password = var.mysql_administrator_password
  sku_name               = var.mysql_sku_name
  backup_retention_days  = var.mysql_backup_retention_days
  geo_redundant_backup_enabled = var.mysql_geo_redundant_backup_enabled

  storage {
    size_gb = var.mysql_storage_gb
  }

  # Include delegated_subnet_id if provided
  delegated_subnet_id    = var.delegated_subnet_id != "" ? var.delegated_subnet_id : null
  private_dns_zone_id    = azurerm_private_dns_zone.mysql.id

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Module      = "database"
  }
}

# MySQL Database
resource "azurerm_mysql_flexible_database" "main" {
  name                = var.mysql_database_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

# Private DNS Zone for MySQL
resource "azurerm_private_dns_zone" "mysql" {
  name                = "${var.mysql_server_name}.private.mysql.database.azure.com"
  resource_group_name = var.resource_group_name
}

# Virtual Network Link for Private DNS Zone
resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                  = "${var.mysql_server_name}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  virtual_network_id    = var.virtual_network_id
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