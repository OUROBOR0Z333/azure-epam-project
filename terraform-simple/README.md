# Simple Frontend Demo

This directory contains a simplified Terraform configuration that deploys only a frontend VM to demonstrate that the application is working, without all the complex backend infrastructure.

## Purpose

Instead of deploying the full Movie Analyst application with:
- MySQL database
- Backend VM
- Frontend VM Scale Set
- Application Gateway
- Complex networking

This simplified version deploys only:
- A single frontend VM running Ubuntu
- Basic networking (VNet, subnet, NSG)
- Public IP for access

This is ideal for:
- Quick demos
- Proof of concept
- Testing connectivity
- Showing the application is working

## Components Deployed

1. **Resource Group** - Contains all resources
2. **Virtual Network** - 10.0.0.0/16
3. **Subnet** - 10.0.1.0/24 for frontend
4. **Network Security Group** - Allows SSH, HTTP, HTTPS
5. **Public IP** - For external access
6. **Network Interface** - Connects VM to network
7. **Linux VM** - Ubuntu 22.04 LTS (Standard_B1ms - Free Tier eligible)

## Prerequisites

- Azure CLI installed and logged in
- Terraform installed
- Azure subscription with appropriate permissions

## Deployment

### Option 1: Interactive Deployment Script

```bash
./deploy-frontend-demo.sh
```

This script will:
1. Check prerequisites
2. Guide you through the deployment process
3. Handle Terraform initialization and apply

### Option 2: Manual Terraform Commands

1. **Create terraform.tfvars**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Review the plan**:
   ```bash
   terraform plan
   ```

4. **Apply the configuration**:
   ```bash
   terraform apply
   ```

## Post-Deployment

After deployment, you'll get outputs showing:
- Public IP address of the VM
- SSH connection string
- Resource group name

You can connect to the VM using SSH:
```bash
ssh azureuser@<PUBLIC_IP>
```

The VM will have Docker installed, and you can deploy your frontend application there.

## Cost Considerations

This deployment uses Azure Free Tier eligible resources:
- Standard_B1ms VM size
- Standard LRS storage
- Pay-as-you-go pricing for other resources

Estimated monthly cost: ~$10-15 for continuous operation.

## Cleanup

To remove all resources:
```bash
terraform destroy
```

Or delete the resource group manually in Azure Portal.

## Customization

You can customize this deployment by:
1. Modifying `main.tf` to change VM size, OS, etc.
2. Updating `variables.tf` to add new configurable parameters
3. Adding additional resources as needed for your demo