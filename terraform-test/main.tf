terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
  backend "azurerm" {}
}

# Declare variables
variable "environment" {
  description = "Environment name (e.g. qa, prod)"
  type        = string
  default     = "qa"
}

provider "azurerm" {
  features {}
}

# Basic resource to test the configuration
resource "azurerm_resource_group" "test" {
  count    = var.environment == "qa" ? 1 : 0  # Only create in qa for testing
  name     = "rg-${var.environment}-terraform-test"
  location = "East US"

  tags = {
    Environment = var.environment
    Project     = "terraform-test"
    Purpose     = "backend-validation"
  }
}