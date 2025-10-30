#!/bin/bash

# Simple Frontend Application Deployment Script
# Deploys the Movie Analyst Frontend application to demonstrate the page is working

set -e  # Exit on any error

echo "=== Deploying Movie Analyst Frontend Application ==="
echo ""

# Check if required tools are installed
echo "🔍 Checking prerequisites..."
if ! command -v ansible &> /dev/null; then
    echo "❌ Error: Ansible is not installed"
    echo "Please install Ansible: sudo apt-get install ansible"
    exit 1
fi

if ! command -v terraform &> /dev/null; then
    echo "❌ Error: Terraform is not installed"
    echo "Please install Terraform"
    exit 1
fi

echo "✅ Prerequisites OK"
echo ""

# Check if the devops-rampup-repo exists and has the movie-analyst-ui directory
echo "📂 Checking for Movie Analyst frontend source code..."
if [ ! -d "/home/ouroboroz/Projects/Epam_Cloud_Project/devops-rampup-repo/movie-analyst-ui" ]; then
    echo "❌ Error: Movie Analyst frontend source code not found"
    echo "Expected directory: /home/ouroboroz/Projects/Epam_Cloud_Project/devops-rampup-repo/movie-analyst-ui"
    exit 1
fi

echo "✅ Found Movie Analyst frontend source code"
echo ""

# Get the frontend VM private IP from Terraform output
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
# Ansible Inventory for Movie Analyst Frontend VM
# Automatically generated for Movie Analyst frontend deployment

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

# Run the Movie Analyst frontend Ansible playbook
echo "🚀 Deploying Movie Analyst frontend application with Ansible..."
echo ""

# Run Ansible playbook
ansible-playbook -i inventory.ini movie-analyst-frontend.yml

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 Success! Movie Analyst frontend application deployed successfully!"
    echo ""
    echo "🔧 To access the demo application:"
    echo "1. Go to Azure Portal"
    echo "2. Navigate to your resource group (rg-demo-movie-analyst-demo)"
    echo "3. Find the Bastion host (bastion-demo-movie-analyst)"
    echo "4. Connect to the VM (vm-frontend-demo) using Bastion"
    echo "5. Open a web browser and go to: http://$FRONTEND_VM_PRIVATE_IP:3030"
    echo ""
    echo "📝 Application Details:"
    echo "- Application: Movie Analyst Frontend (Node.js/Express with EJS)"
    echo "- Port: 3030"
    echo "- Directory: /home/azureuser/movie-analyst-ui"
    echo "- Service: movie-analyst-ui (managed by systemd)"
    echo "- Backend URL: localhost:3000 (for demo purposes)"
    echo ""
else
    echo ""
    echo "❌ Error: Ansible playbook failed to deploy Movie Analyst frontend application"
    echo "Check the error output above for details"
    exit 1
fi

echo "=== Movie Analyst Frontend Deployment Complete ==="