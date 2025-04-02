variable "azure_location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "westeurope"
}

variable "azure_resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "webserver-rg"
}

variable "azure_vm_size" {
  description = "Size of the Azure VM"
  type        = string
  default     = "Standard_B1s"
}

variable "azure_admin_username" {
  description = "Admin username for the Azure VM"
  type        = string
  default     = "adminuser"
}

