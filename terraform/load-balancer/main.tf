# Load Balancer Module
# Creates Application Gateway for load balancing

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Public IP for Application Gateway
resource "azurerm_public_ip" "main" {
  name                = "${var.app_gateway_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Module      = "load-balancer"
  }
}

# Application Gateway
resource "azurerm_application_gateway" "main" {
  name                = var.app_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = var.app_gateway_sku
    tier     = var.app_gateway_tier
    capacity = var.app_gateway_capacity
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.public_subnet_id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "appGatewayFrontendIP"
    public_ip_address_id = azurerm_public_ip.main.id
  }

  backend_address_pool {
    name = var.backend_address_pool_frontend_name
  }

  backend_address_pool {
    name = var.backend_address_pool_backend_name
  }

  backend_http_settings {
    name                  = var.backend_http_settings_frontend_name
    cookie_based_affinity = "Disabled"
    path                  = var.frontend_path
    port                  = var.frontend_port
    protocol              = "Http"
    request_timeout       = 60
  }

  backend_http_settings {
    name                  = var.backend_http_settings_backend_name
    cookie_based_affinity = "Disabled"
    path                  = var.backend_path
    port                  = var.backend_port
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "frontend-listener"
    frontend_ip_configuration_name = "appGatewayFrontendIP"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "frontend-rule"
    rule_type                  = "PathBasedRouting"
    http_listener_name         = "frontend-listener"
    url_path_map_name          = "frontend-path-map"
    priority                   = 100
  }

  url_path_map {
    name = "frontend-path-map"

    default_backend_address_pool_name  = var.backend_address_pool_frontend_name
    default_backend_http_settings_name = var.backend_http_settings_frontend_name

    path_rule {
      name               = "backend-api-rule"
      paths              = var.backend_path_patterns
      backend_address_pool_name  = var.backend_address_pool_backend_name
      backend_http_settings_name = var.backend_http_settings_backend_name
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Module      = "load-balancer"
  }
}

# Outputs
output "application_gateway_id" {
  description = "The ID of the application gateway"
  value       = azurerm_application_gateway.main.id
}

output "application_gateway_name" {
  description = "The name of the application gateway"
  value       = azurerm_application_gateway.main.name
}

output "frontend_ip_address" {
  description = "The public IP address of the application gateway"
  value       = azurerm_public_ip.main.ip_address
}

output "application_gateway_ip" {
  description = "The public IP address of the application gateway"
  value       = azurerm_public_ip.main.ip_address
  depends_on  = [azurerm_application_gateway.main]
}