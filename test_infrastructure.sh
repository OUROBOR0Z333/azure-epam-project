#!/bin/bash

# Infrastructure Test Script
# This script tests the basic infrastructure components before full deployment

set -e  # Exit on any error

echo "========================================================="
echo "Azure Infrastructure Test Script"
echo "========================================================="

# Configuration
RESOURCE_GROUP="rg-qa-infra-test"
LOCATION="East US"
STORAGE_ACCOUNT_NAME="tfstateqa1367"  # Your existing storage
STORAGE_CONTAINER="tfstate"

# Function to print colored output
print_status() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[1;32m[SUCCESS]\033[0m $1"
}

print_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

# Function to validate prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."

    # Check if az command exists
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed"
        exit 1
    fi

    # Check if terraform command exists
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed"
        exit 1
    fi

    # Check if Azure is authenticated
    if ! az account show &> /dev/null; then
        print_error "Azure CLI is not authenticated"
        exit 1
    fi

    print_success "Prerequisites check passed"
}

# Function to validate storage backend
test_storage_backend() {
    print_status "Testing storage backend accessibility..."

    # Attempt to list blobs in the container
    if az storage blob list \
        --account-name $STORAGE_ACCOUNT_NAME \
        --container-name $STORAGE_CONTAINER \
        --account-key $(az storage account keys list --resource-group rg-qa-tfstate --account-name $STORAGE_ACCOUNT_NAME --query "[0].value" -o tsv) &> /dev/null; then
        print_success "Storage backend is accessible"
    else
        print_error "Cannot access storage backend"
        exit 1
    fi
}

# Function to test basic resource creation
test_resource_creation() {
    print_status "Testing basic resource creation..."

    # Create a temporary resource group for testing
    print_status "Creating temporary resource group: $RESOURCE_GROUP"
    az group create --name $RESOURCE_GROUP --location "$LOCATION" --tags "purpose=test" &> /dev/null

    # Verify resource group creation
    if az group show --name $RESOURCE_GROUP &> /dev/null; then
        print_success "Resource group created successfully"
    else
        print_error "Failed to create resource group"
        exit 1
    fi

    # Create a test resource (network security group)
    TEST_NSG_NAME="nsg-test-$(date +%s)"
    print_status "Creating test resource: $TEST_NSG_NAME"
    az network nsg create \
        --resource-group $RESOURCE_GROUP \
        --name $TEST_NSG_NAME \
        --tags "purpose=test" &> /dev/null

    # Verify the resource
    if az network nsg show --resource-group $RESOURCE_GROUP --name $TEST_NSG_NAME &> /dev/null; then
        print_success "Test resource created and verified"
    else
        print_error "Failed to create test resource"
        # Clean up and exit
        az group delete --name $RESOURCE_GROUP --yes &> /dev/null
        exit 1
    fi

    # Clean up test resources
    print_status "Cleaning up test resources..."
    az group delete --name $RESOURCE_GROUP --yes --no-wait &> /dev/null
    print_success "Test resources cleaned up"
}

# Main execution
main() {
    print_status "Starting infrastructure test..."

    check_prerequisites
    test_storage_backend
    test_resource_creation

    print_success "All infrastructure tests passed!"
    echo ""
    print_status "Infrastructure is ready for deployment of:"
    print_status "  - Virtual Network with public and private subnets"
    print_status "  - Azure Database for MySQL"
    print_status "  - Application Gateway"
    print_status "  - VMs for backend and frontend services"
    print_status "  - Azure Bastion for secure access"
}

# Run the main function
main "$@"