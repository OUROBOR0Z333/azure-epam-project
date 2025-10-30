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

variable "virtual_network_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet-main"
}

variable "address_space" {
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

variable "database_subnet_address_prefix" {
  description = "Address prefix for the database subnet"
  type        = string
  default     = "10.0.4.0/24"
}

variable "network_security_group_prefix" {
  description = "Prefix for naming network security groups"
  type        = string
  default     = "nsg"
}

variable "ssh_access_cidr" {
  description = "CIDR block for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}