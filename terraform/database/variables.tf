variable "environment" {
  description = "The environment name (e.g. qa, prod)"
  type        = string
  default     = "qa"
}

variable "project_name" {
  description = "The project name"
  type        = string
  default     = "movie-analyst"
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

variable "mysql_server_name" {
  description = "Name of the MySQL server"
  type        = string
}

variable "mysql_version" {
  description = "MySQL version to use"
  type        = string
  default     = "8.0"
}

variable "mysql_administrator_login" {
  description = "Administrator login for MySQL server"
  type        = string
  default     = "mysqladmin"
}

variable "mysql_administrator_password" {
  description = "Administrator password for MySQL server"
  type        = string
  sensitive   = true
}

variable "mysql_sku_name" {
  description = "SKU name for MySQL Flexible Server (Free Tier Compatible)"
  type        = string
  default     = "B_Standard_B1ms"  # Free Tier Compatible SKU for Flexible Server
}

variable "mysql_storage_gb" {
  description = "Storage size for MySQL Flexible Server in GB (Free Tier minimum is 20GB)"
  type        = number
  default     = 20  # 20GB - Minimum for Free Tier Flexible Server
}

variable "mysql_backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}



variable "mysql_database_name" {
  description = "Name of the MySQL database"
  type        = string
  default     = "moviedb"
}

variable "virtual_network_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "private_subnet_name" {
  description = "Name of the private subnet"
  type        = string
}

variable "delegated_subnet_id" {
  description = "ID of the delegated subnet for MySQL (optional for Single Server)"
  type        = string
  default     = ""
}