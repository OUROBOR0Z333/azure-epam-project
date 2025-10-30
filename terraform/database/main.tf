# Azure Database Module (MySQL Single Server - Free Tier Compatible)
# Creates Azure Database for MySQL Single Server

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
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

# MySQL Single Server (Free Tier Compatible)
resource "azurerm_mysql_server" "main" {
  name                = var.mysql_server_name
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login          = var.mysql_administrator_login
  administrator_login_password = var.mysql_administrator_password
  version                      = var.mysql_version
  ssl_enforcement_enabled      = true

  # Use a free tier compatible SKU
  sku_name = var.mysql_sku_name
  storage_mb = var.mysql_storage_gb * 1024

  backup_retention_days        = var.mysql_backup_retention_days
  geo_redundant_backup_enabled = var.mysql_geo_redundant_backup_enabled

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Module      = "database"
  }
}

# MySQL Database
resource "azurerm_mysql_database" "main" {
  name                = var.mysql_database_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.main.name
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
  virtual_network_id    = data.azurerm_virtual_network.main.id
}

# Outputs
output "mysql_server_id" {
  description = "The ID of the MySQL server"
  value       = azurerm_mysql_server.main.id
}

output "mysql_server_name" {
  description = "The name of the MySQL server"
  value       = azurerm_mysql_server.main.name
}

output "mysql_server_fqdn" {
  description = "The FQDN of the MySQL server"
  value       = azurerm_mysql_server.main.fqdn
}

output "mysql_database_id" {
  description = "The ID of the MySQL database"
  value       = azurerm_mysql_database.main.id
}

output "mysql_database_name" {
  description = "The name of the MySQL database"
  value       = azurerm_mysql_database.main.name
}

output "private_dns_zone_id" {
  description = "The ID of the private DNS zone"
  value       = azurerm_private_dns_zone.mysql.id
}