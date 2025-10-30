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

variable "app_gateway_name" {
  description = "Name of the application gateway"
  type        = string
  default     = "appgw-main"
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

variable "public_subnet_id" {
  description = "ID of the public subnet"
  type        = string
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

variable "frontend_path" {
  description = "Path prefix for frontend requests"
  type        = string
  default     = "/"
}

variable "frontend_port" {
  description = "Port for frontend service"
  type        = number
  default     = 3030
}

variable "backend_path" {
  description = "Path prefix for backend requests"
  type        = string
  default     = "/api"
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