variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
}

variable "vm_size" {
  description = "Size of the Azure VM"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the Azure VM"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the storage account containing Ansible files"
  type        = string
}

variable "storage_container_name" {
  description = "Name of the storage container containing Ansible files"
  type        = string
}

variable "storage_sas_token" {
  description = "SAS token for accessing storage"
  type        = string
  sensitive   = true
}
