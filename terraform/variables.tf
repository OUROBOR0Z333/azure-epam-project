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
  description = "Name of the resource group to create"
  type        = string
}

variable "location" {
  description = "Azure region for the resources"
  type        = string
  default     = "East US"
}

variable "virtual_network_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet-movie-analyst"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_name" {
  description = "Name of the public subnet"
  type        = string
  default     = "snet-public"
}

variable "private_subnet_name" {
  description = "Name of the private subnet"
  type        = string
  default     = "snet-private"
}

variable "bastion_subnet_name" {
  description = "Name of the bastion subnet"
  type        = string
  default     = "AzureBastionSubnet"
}

variable "public_subnet_address_prefix" {
  description = "Address prefix for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_address_prefix" {
  description = "Address prefix for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "bastion_subnet_address_prefix" {
  description = "Address prefix for the bastion subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "ssh_access_cidr" {
  description = "CIDR block for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "mysql_server_name" {
  description = "Name of the MySQL server"
  type        = string
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

variable "mysql_version" {
  description = "MySQL version to use"
  type        = string
  default     = "8.0.21"
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

variable "vm_name_prefix" {
  description = "Prefix for VM names"
  type        = string
  default     = "vm-movie-analyst"
}

variable "backend_vm_size" {
  description = "Size of the backend VM"
  type        = string
  default     = "Standard_B2s"
}

variable "frontend_vm_size" {
  description = "Size of the frontend VMs in the scale set"
  type        = string
  default     = "Standard_B2s"
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

variable "app_gateway_name" {
  description = "Name of the application gateway"
  type        = string
  default     = "appgw-movie-analyst"
}

variable "app_gateway_sku" {
  description = "SKU of the application gateway"
  type        = string
  default     = "Standard_v2"
}

variable "app_gateway_tier" {
  description = "Tier of the application gateway"
  type        = string
  default     = "Standard_v2"
}

variable "app_gateway_capacity" {
  description = "Capacity of the application gateway"
  type        = number
  default     = 2
}

variable "backend_address_pool_frontend_name" {
  description = "Name of the backend address pool for frontend"
  type        = string
  default     = "frontend-pool"
}

variable "backend_address_pool_backend_name" {
  description = "Name of the backend address pool for backend"
  type        = string
  default     = "backend-pool"
}

variable "backend_http_settings_frontend_name" {
  description = "Name of the backend HTTP settings for frontend"
  type        = string
  default     = "frontend-settings"
}

variable "backend_http_settings_backend_name" {
  description = "Name of the backend HTTP settings for backend"
  type        = string
  default     = "backend-settings"
}

variable "frontend_port" {
  description = "Port for frontend service"
  type        = number
  default     = 3030
}

variable "backend_port" {
  description = "Port for backend service"
  type        = number
  default     = 3000
}

variable "backend_path_patterns" {
  description = "Path patterns that route to the backend"
  type        = list(string)
  default     = ["/api/*", "/movies/*", "/reviewers/*", "/publications/*", "/pending/*"]
}