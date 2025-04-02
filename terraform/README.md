# Multi-Cloud Webserver Deployment with Terraform

This project demonstrates how to deploy webservers on both AWS and Azure using Terraform for infrastructure provisioning and local Ansible execution for configuration management.

## Project Structure

```
terraform/
├── aws/                      # AWS-specific Terraform configuration
│   ├── main.tf               # AWS infrastructure definition with embedded Ansible
│   └── variables.tf          # AWS variables
├── azure/                    # Azure-specific Terraform configuration
│   ├── main.tf               # Azure infrastructure definition with embedded Ansible
│   └── variables.tf          # Azure variables
├── common/                   # Shared resources
│   ├── storage.tf            # S3 and Azure Blob Storage configuration
│   └── variables.tf          # Common variables
├── ansible/                  # Ansible playbooks and templates
│   ├── webserver_setup.yml   # Main Ansible playbook
│   ├── templates/            # Jinja2 templates
│   └── test/                 # Docker-based testing environment
├── main.tf                   # Main Terraform configuration
├── variables.tf              # Common variables
└── terraform.tfvars.example  # Example variable values
```

## Prerequisites

1. Terraform (>= 1.0.0)
2. AWS CLI configured with appropriate credentials
3. Azure CLI configured with appropriate credentials

## Setup

1. Clone this repository
2. Create a `terraform.tfvars` file based on the example
3. Run `terraform init` to initialize the project
4. Run `terraform apply` to create the infrastructure and configure the webservers

## How It Works

1. Terraform provisions the storage resources (S3 bucket and Azure Blob Storage)
2. Ansible playbooks and templates are uploaded to both storage services
3. Terraform provisions the infrastructure on both AWS and Azure
4. During VM provisioning, Terraform includes scripts to:
   - Install Ansible on each VM
   - Download necessary playbook files from S3/Blob Storage
   - Run Ansible locally on each VM to configure the webserver

## Testing Locally

Before deploying to the cloud, you can test the Ansible playbook locally using Docker:

```bash
cd ansible/test
./test-playbook.sh
```

This will:
1. Create Docker containers simulating AWS and Azure environments
2. Run the Ansible playbook in each container
3. Start the webservers for testing
4. Make them available at http://localhost:8080 (AWS) and http://localhost:8081 (Azure)

See the [testing documentation](ansible/test/README.md) for more details.

## Features

- Multi-cloud deployment (AWS and Azure)
- Infrastructure as Code with Terraform
- Self-configuring VMs with embedded Ansible
- No need for local Ansible installation
- Distribution-agnostic webserver setup (works on Debian/Ubuntu and RHEL/CentOS/Amazon Linux)
- Independent configuration of each cloud platform
- Centralized storage of configuration files in cloud storage
- Local testing environment using Docker

## Accessing the Webservers

After deployment completes, the public IP addresses of both webservers will be displayed in the Terraform output. You can access the webservers by visiting:

- AWS: http://<aws_webserver_public_ip>
- Azure: http://<azure_webserver_public_ip>

## Architecture

This solution uses a "configuration injection" approach where:

1. Infrastructure is provisioned using Terraform
2. Configuration scripts are embedded in the VM startup process
3. Each VM installs and runs Ansible locally
4. Configuration files are retrieved from cloud storage
5. The webserver is configured without requiring external access

This approach eliminates the need for:
- SSH key management for configuration
- Local Ansible installation
- Managing inventory files
- Network connectivity from the deployment machine to the VMs for configuration
- Git repository cloning on the VMs
