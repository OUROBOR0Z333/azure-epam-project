# Simple Frontend Demo with Azure Bastion

This directory contains a simplified Terraform configuration that deploys only a frontend VM with secure Azure Bastion access, perfect for demonstrating that the application is working without all the complex backend infrastructure.

## Purpose

Instead of deploying the full Movie Analyst application with:
- MySQL database
- Backend VM
- Frontend VM Scale Set
- Application Gateway
- Complex networking

This simplified version deploys only:
- A single frontend VM running Ubuntu (private subnet)
- Azure Bastion for secure access
- Basic networking with proper security

This is ideal for:
- Quick demos with secure access
- Proof of concept
- Testing connectivity
- Showing the application is working
- Using Ansible for configuration management

## Components Deployed

1. **Resource Group** - Contains all resources
2. **Virtual Network** - 10.0.0.0/16
3. **Public Subnet** - 10.0.1.0/24 (for future public resources)
4. **Private Subnet** - 10.0.2.0/24 (for frontend VM)
5. **Azure Bastion Subnet** - 10.0.3.0/24
6. **Network Security Groups** - Proper security rules
7. **Azure Bastion Host** - Secure RDP/SSH access
8. **Linux VM** - Ubuntu 22.04 LTS (Standard_B1ms - Free Tier eligible)

## Architecture Benefits

✅ **Secure Access** - No direct public IP on VM, access via Azure Bastion only
✅ **Ansible Friendly** - Secure SSH access for configuration management
✅ **Cost Effective** - Uses Free Tier eligible resources
✅ **Production Ready** - Follows Azure best practices
✅ **Easy Management** - Bastion provides browser-based SSH/RDP

## Prerequisites

- Azure CLI installed and logged in
- Terraform installed
- Azure subscription with appropriate permissions

## Deployment

### Option 1: GitHub Actions (Recommended)

```bash
# Run the workflow in GitHub Actions
# Navigate to Actions -> 1.1-Simple-Frontend-Demo-Deployment
```

### Option 2: Manual Terraform Commands

1. **Create terraform.tfvars** (if not already created):
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your actual values
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

## Accessing the VM

After deployment, you can access the VM through Azure Bastion:

1. **Via Azure Portal**:
   - Go to Azure Portal
   - Navigate to the Bastion resource
   - Click "Connect" and enter VM credentials

2. **Via Azure CLI** (if configured):
   ```bash
   az network bastion ssh --name bastion-demo-movie-analyst-demo --resource-group rg-demo-movie-analyst-demo --target-resource-id /subscriptions/YOUR-SUBSCRIPTION-ID/resourceGroups/rg-demo-movie-analyst-demo/providers/Microsoft.Compute/virtualMachines/vm-frontend-demo
   ```

## Using Ansible for Configuration

The VM is perfectly set up for Ansible management:

1. **Inventory File**:
   ```ini
   [frontend]
   vm-frontend-demo ansible_host=10.0.2.4  # Private IP from outputs
   
   [frontend:vars]
   ansible_user=azureuser
   ansible_ssh_private_key_file=~/.ssh/id_rsa
   ```

2. **Ansible Playbook**:
   ```yaml
   - hosts: frontend
     become: yes
     tasks:
       - name: Install Docker
         apt:
           name: docker.io
           state: present
           update_cache: yes
       
       - name: Start Docker service
         systemd:
           name: docker
           state: started
           enabled: yes
   ```

3. **Running Ansible through Bastion**:
   You'll need to configure SSH proxy through Bastion or use direct connection if you have VPN/site-to-site connectivity.

## Post-Deployment

After deployment, you'll get outputs showing:
- Bastion public IP address
- Frontend VM private IP address
- Resource group name

## Cost Considerations

This deployment uses Azure Free Tier eligible resources:
- Standard_B1ms VM size
- Standard LRS storage
- Azure Bastion (has usage-based pricing)

Estimated monthly cost: ~$20-30 for continuous operation (mostly Bastion).

## Cleanup

To remove all resources:
```bash
terraform destroy
```

Or delete the resource group manually in Azure Portal.

## Customization

You can customize this deployment by:
1. Modifying `main.tf` to change VM size, OS, etc.
2. Adding additional resources as needed for your demo