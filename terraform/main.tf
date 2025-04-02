terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Azure Provider configuration
provider "azurerm" {
  features {}
}

# Create Azure Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.azure_resource_group_name
  location = var.azure_location
}

# Create Storage Account for Ansible files
resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_storage_account" "ansible_files" {
  name                     = "ansiblefiles${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_storage_container" "ansible_files" {
  name                  = "ansible-files"
  storage_account_name  = azurerm_storage_account.ansible_files.name
  container_access_type = "private"
}

# Upload Ansible files to Azure Blob Storage
resource "azurerm_storage_blob" "webserver_setup_yml" {
  name                   = "webserver_setup.yml"
  storage_account_name   = azurerm_storage_account.ansible_files.name
  storage_container_name = azurerm_storage_container.ansible_files.name
  type                   = "Block"
  source                 = "${path.module}/ansible/webserver_setup.yml"
}

resource "azurerm_storage_blob" "index_html_template" {
  name                   = "templates/index.html.j2"
  storage_account_name   = azurerm_storage_account.ansible_files.name
  storage_container_name = azurerm_storage_container.ansible_files.name
  type                   = "Block"
  source                 = "${path.module}/ansible/templates/index.html.j2"
}

resource "azurerm_storage_blob" "ansible_cfg" {
  name                   = "ansible.cfg"
  storage_account_name   = azurerm_storage_account.ansible_files.name
  storage_container_name = azurerm_storage_container.ansible_files.name
  type                   = "Block"
  source                 = "${path.module}/ansible/ansible.cfg"
}

# Generate SAS token for Azure blobs
data "azurerm_storage_account_sas" "ansible_files" {
  connection_string = azurerm_storage_account.ansible_files.primary_connection_string
  https_only        = true

  resource_types {
    service   = false
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = timestamp()
  expiry = timeadd(timestamp(), "8760h") # 1 year

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = true
    add     = false
    create  = false
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}

# Include Azure resources
module "azure_webserver" {
  source = "./azure"
  
  vm_size              = var.azure_vm_size
  admin_username       = var.azure_admin_username
  location             = var.azure_location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_name = azurerm_storage_account.ansible_files.name
  storage_container_name = azurerm_storage_container.ansible_files.name
  storage_sas_token    = data.azurerm_storage_account_sas.ansible_files.sas
  
  depends_on = [
    azurerm_storage_blob.webserver_setup_yml,
    azurerm_storage_blob.index_html_template,
    azurerm_storage_blob.ansible_cfg
  ]
}

# Output the public IP of the webserver
output "azure_webserver_public_ip" {
  value = module.azure_webserver.public_ip
}
