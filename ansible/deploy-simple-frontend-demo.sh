#!/bin/bash

# Simple Frontend Demo Deployment Script
# Deploys a basic web server to demonstrate the page is working

set -e  # Exit on any error

echo "=== Simple Frontend Demo Deployment ==="
echo ""

# Check if required tools are installed
echo "🔍 Checking prerequisites..."
if ! command -v ansible &> /dev/null; then
    echo "❌ Error: Ansible is not installed"
    echo "Please install Ansible: sudo apt-get install ansible"
    exit 1
fi

echo "✅ Prerequisites OK"
echo ""

# Get Terraform output for the frontend VM private IP
echo "📡 Getting frontend VM information from Terraform..."
cd /home/ouroboroz/Projects/Epam_Cloud_Project/azure-epam-project/terraform-simple

# Try to get the frontend VM private IP
FRONTEND_VM_PRIVATE_IP=$(terraform output -raw frontend_vm_private_ip 2>/dev/null || echo "")

if [ -z "$FRONTEND_VM_PRIVATE_IP" ]; then
    echo "❌ Error: Could not get frontend VM private IP from Terraform output"
    echo "Make sure the Terraform deployment is complete and you're in the correct directory"
    exit 1
fi

echo "✅ Got frontend VM private IP: $FRONTEND_VM_PRIVATE_IP"
echo ""

# Create or update the Ansible inventory with the VM information
echo "📝 Creating/updating Ansible inventory..."
cd /home/ouroboroz/Projects/Epam_Cloud_Project/azure-epam-project/ansible

# Create inventory file with the VM IP
cat > inventory.ini << EOF
# Ansible Inventory for Frontend Demo VM
# Automatically generated for simple frontend demo

[frontend]
vm-frontend-demo ansible_host=$FRONTEND_VM_PRIVATE_IP ansible_user=azureuser

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOF

echo "✅ Inventory created with VM IP: $FRONTEND_VM_PRIVATE_IP"
echo ""

# Display inventory for verification
echo "📋 Inventory contents:"
cat inventory.ini
echo ""

# Run the simple Ansible playbook to deploy the frontend demo
echo "🚀 Deploying frontend demo application with Ansible..."
echo ""

# Run Ansible playbook
ansible-playbook -i inventory.ini simple-frontend-demo.yml

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 Success! Frontend demo application deployed successfully!"
    echo ""
    echo "🔧 To access the demo application:"
    echo "1. Go to Azure Portal"
    echo "2. Navigate to your resource group (rg-demo-movie-analyst-frontend-demo)"
    echo "3. Find the Bastion host (bastion-demo-movie-analyst-frontend-demo)"
    echo "4. Connect to the VM (vm-frontend-demo) using Bastion"
    echo "5. Open a web browser and go to: http://$FRONTEND_VM_PRIVATE_IP"
    echo ""
    echo "You should see the Movie Analyst Frontend Demo page showing the application is working!"
    echo ""
else
    echo ""
    echo "❌ Error: Ansible playbook failed to deploy application"
    echo "Check the error output above for details"
    exit 1
fi

echo "=== Deployment Complete ==="