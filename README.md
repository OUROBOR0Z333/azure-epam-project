# Azure EPAM Project

This repository contains the infrastructure and deployment configurations for migrating the Movie Analyst application from GCP to Microsoft Azure.

## Project Overview

The goal of this project is to replicate the existing GCP infrastructure on Microsoft Azure using Infrastructure as Code (Terraform), with equivalent services and architecture.

## Current Status

- [ ] Azure infrastructure Terraform configuration (planned)
- [ ] Network infrastructure (planned)
- [ ] Compute resources (planned)
- [ ] Database setup (planned)
- [ ] Load balancer configuration (planned)
- [ ] Application deployment scripts (planned)
- [ ] CI/CD pipelines (planned)

## Architecture

The Azure architecture will mirror the original GCP setup with:
- Virtual Network with public and private subnets
- Azure Bastion for secure access
- Application Gateway for traffic routing
- Azure Database for MySQL
- Backend and frontend VMs (VMSS)
- Network Security Groups

## Prerequisites

1. Azure account with appropriate permissions
2. Azure CLI installed and authenticated
3. Terraform installed (version 1.0+)
4. SSH key pair for VM access

## Getting Started

1. Clone the repository
2. Configure your Azure credentials
3. Update Terraform variables with your values
4. Deploy infrastructure using Terraform

## Contributing

This project is part of the EPAM Cloud project for learning Azure infrastructure deployment.