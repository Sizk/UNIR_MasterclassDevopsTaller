# Azure Webserver Terraform Project

This project deploys a simple webserver in Azure using Terraform. The webserver displays the IP address and hostname of the machine hosting it.

## Project Structure

```
terraform/
├── azure/                # Azure-specific configuration
│   ├── main.tf
│   └── variables.tf
├── main.tf               # Main Terraform configuration
├── variables.tf          # Variable definitions
└── terraform.tfvars      # Variable values
```

## Prerequisites

1. [Terraform](https://www.terraform.io/downloads.html) (v1.0.0 or newer)
2. Azure CLI configured with appropriate credentials

## Setup Instructions

1. Clone this repository
2. Navigate to the terraform directory
3. Edit `terraform.tfvars` with your specific configuration values if needed

## Deployment

1. Initialize Terraform:
   ```
   terraform init
   ```

2. Preview the changes:
   ```
   terraform plan
   ```

3. Apply the changes:
   ```
   terraform apply
   ```

4. When prompted, type `yes` to confirm

## Accessing the Webserver

After deployment completes, Terraform will output the public IP address of the webserver:

- Azure Webserver: `http://<azure_webserver_public_ip>`

Visit this URL in your web browser to see the server information.

## Cleanup

To destroy all resources created by this project:

```
terraform destroy
```

When prompted, type `yes` to confirm.

## Security Note

This project is for demonstration purposes only. For production use, consider:

- Restricting SSH access to specific IP ranges
- Using SSH keys instead of passwords for Azure VMs
- Implementing proper network segmentation
- Adding HTTPS support
- Implementing proper logging and monitoring
