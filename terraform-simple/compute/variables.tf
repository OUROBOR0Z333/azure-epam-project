# Variables for the Simplified Compute Module
# Defines variables for frontend VM deployment

variable "environment" {
  description = "The environment name (e.g. demo, test)"
  type        = string
  default     = "demo"
}

variable "project_name" {
  description = "The project name"
  type        = string
  default     = "movie-analyst-demo"
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

variable "vm_name_prefix" {
  description = "Prefix for VM names"
  type        = string
  default     = "vm-movie-analyst"
}

variable "frontend_vm_size" {
  description = "Size of the frontend VMs in the scale set"
  type        = string
  default     = "Standard_B1ms"  # Free Tier eligible
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

variable "private_subnet_id" {
  description = "ID of the private subnet"
  type        = string
}