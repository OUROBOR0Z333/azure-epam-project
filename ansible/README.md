# 🎬 Movie Analyst Frontend Demo

This directory contains a simplified deployment for demonstrating that the Movie Analyst frontend application is working correctly.

## 🎯 Purpose

Instead of deploying the full complex infrastructure (with databases, backend services, etc.), this deployment focuses on:

✅ **Frontend VM Only** - Just one VM to demonstrate the page is working  
✅ **Simple Architecture** - Minimal resources for quick deployment  
✅ **Cost Effective** - Uses Azure Free Tier eligible resources  
✅ **Easy Access** - Azure Bastion for secure VM access  

## 📁 What Gets Deployed

1. **Resource Group**: `rg-demo-movie-analyst-demo`
2. **Virtual Network**: Basic networking with proper security
3. **Frontend VM**: Ubuntu 22.04 LTS (Standard_B1ms - Free Tier eligible)
4. **Azure Bastion**: Secure RDP/SSH access without public IPs
5. **Movie Analyst Frontend**: Node.js/Express application with EJS templates

## 🚀 How to Deploy

### Option 1: GitHub Actions (Recommended)
1. Go to your GitHub repository
2. Navigate to **Actions** tab
3. Run **"2.1-free-tier-infrastructure-deployment"** workflow
4. Select **"demo"** environment
5. Deployment takes ~10-15 minutes

### Option 2: Manual Deployment
```bash
# Deploy infrastructure
cd terraform-simple
terraform init
terraform apply

# Deploy frontend application
cd ../ansible
./deploy-frontend-app.sh
```

## 🔧 Accessing the Application

After deployment:
1. **Via Azure Portal**:
   - Go to Azure Portal
   - Navigate to the Bastion resource
   - Click "Connect" and enter VM credentials
2. **Access the Application**:
   - Open browser in VM
   - Go to: `http://<FRONTEND_VM_PRIVATE_IP>:3030`
3. **You should see the Movie Analyst Frontend Demo page**

## 💰 Cost Information

- **Very Low**: ~$5-10/month for continuous operation
- **Free Tier**: Standard_B1ms VM size
- **Azure Bastion**: ~$0.05/hour when active

## 🧹 Cleanup

To remove all resources:
```bash
cd terraform-simple
terraform destroy
```

## 📝 Notes

- This is a simplified demo focused on showing the frontend application works
- No backend database or API services are included
- Perfect for demonstrating that the page is working without complex infrastructure