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
  default     = "8.0.21"
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
  description = "SKU name for MySQL server"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "mysql_storage_gb" {
  description = "Storage size for MySQL server in GB"
  type        = number
  default     = 20
}

variable "mysql_backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "mysql_geo_redundant_backup_enabled" {
  description = "Enable geo-redundant backups"
  type        = bool
  default     = false
}

variable "mysql_database_name" {
  description = "Name of the MySQL database"
  type        = string
  default     = "moviedb"
}

variable "delegated_subnet_id" {
  description = "ID of the delegated subnet for MySQL"
  type        = string
  default     = ""
}

variable "virtual_network_id" {
  description = "ID of the virtual network"
  type        = string
}