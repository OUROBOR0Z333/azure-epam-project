#!/bin/bash

# Simple Frontend Demo Deployment Script with Azure Bastion
# Deploys frontend VM with secure Bastion access for Ansible configuration

echo "=== Simple Frontend Demo Deployment with Azure Bastion ==="
echo "This script will deploy a simplified version with frontend VM and Azure Bastion"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "Error: Azure CLI is not installed"
    echo "Please install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "Error: Terraform is not installed"
    echo "Please install Terraform: https://learn.hashicorp.com/tutorials/terraform/install-cli"
    exit 1
fi

# Login to Azure (if not already logged in)
echo "Checking Azure authentication..."
az account show &> /dev/null
if [ $? -ne 0 ]; then
    echo "Please login to Azure:"
    az login
    if [ $? -ne 0 ]; then
        echo "Error: Failed to login to Azure"
        exit 1
    fi
fi

# Set working directory
cd "$(dirname "$0")"

echo "Current directory: $(pwd)"
echo "Terraform files found:"
ls -la *.tf* 2>/dev/null || echo "No Terraform files found in current directory"

# Ask user to confirm
echo ""
echo "Ready to deploy the simple frontend demo with Azure Bastion."
echo "This will create:"
echo "  - Resource Group"
echo "  - Virtual Network with subnets"
echo "  - Network Security Groups"
echo "  - Azure Bastion Host"
echo "  - Private Linux Virtual Machine (Ubuntu)"
echo ""
read -p "Do you want to proceed? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

# Initialize Terraform
echo "Initializing Terraform..."
terraform init
if [ $? -ne 0 ]; then
    echo "Error: Terraform init failed"
    exit 1
fi

# Validate configuration
echo "Validating Terraform configuration..."
terraform validate
if [ $? -ne 0 ]; then
    echo "Error: Terraform validation failed"
    exit 1
fi

# Create terraform.tfvars if it doesn't exist
if [ ! -f "terraform.tfvars" ]; then
    echo "Creating terraform.tfvars from example..."
    cp terraform.tfvars.example terraform.tfvars
    echo "Please edit terraform.tfvars with your actual values"
    echo "Especially update the admin_password and ssh_public_key"
    exit 1
fi

# Plan the deployment
echo "Planning the deployment..."
terraform plan -out=tfplan
if [ $? -ne 0 ]; then
    echo "Error: Terraform plan failed"
    exit 1
fi

# Ask user to confirm apply
echo ""
echo "Terraform plan completed successfully."
read -p "Do you want to apply the plan? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Apply cancelled."
    exit 0
fi

# Apply the deployment
echo "Applying the deployment..."
terraform apply tfplan
if [ $? -ne 0 ]; then
    echo "Error: Terraform apply failed"
    exit 1
fi

echo ""
echo "=== Deployment completed successfully! ==="
echo "Check the outputs for Bastion access information."
echo ""
echo "You can now access your VM through Azure Bastion:"
echo "1. Go to Azure Portal"
echo "2. Navigate to the Bastion resource"
echo "3. Click 'Connect' and enter VM credentials"
echo ""
echo "For Ansible configuration, use the private IP shown in outputs."

exit 0