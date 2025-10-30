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

variable "location" {
  description = "Azure region for the resources"
  type        = string
  default     = "East US"
}

variable "ssh_public_key" {
  description = "SSH public key for accessing the VM"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDhfnNIUcFBL8P30A2/Bz9VQWbY7LkQ3YK5cY0N2vFJ1dG3hE5tG2bY8zLkQ3YK5cY0N2vFJ1dG3hE5tG2bY8z sample-key"
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}