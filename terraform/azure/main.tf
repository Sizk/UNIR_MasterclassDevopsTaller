# Generate random password for VM
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "webserver-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Create a subnet
resource "azurerm_subnet" "subnet" {
  name                 = "webserver-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a public IP
resource "azurerm_public_ip" "public_ip" {
  name                = "webserver-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

# Create a network security group
resource "azurerm_network_security_group" "nsg" {
  name                = "webserver-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create a network interface
resource "azurerm_network_interface" "nic" {
  name                = "webserver-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create a Linux VM
resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "azure-webserver"
  resource_group_name            = var.resource_group_name
  location                       = var.location
  size                          = var.vm_size
  admin_username                 = var.admin_username
  admin_password                 = random_password.password.result
  disable_password_authentication = false
  
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
#cloud-config
write_files:
  - path: /var/lib/cloud/scripts/per-boot/install-and-configure.sh
    permissions: '0755'
    content: |
      #!/bin/bash
      # Update system and install dependencies
      apt-get update
      apt-get install -y python3 python3-pip curl
      pip3 install --upgrade requests
      pip3 install ansible azure-cli

      # Create ansible directory structure
      mkdir -p /home/${var.admin_username}/ansible/templates

      # Download Ansible files from Azure Blob Storage
      export AZURE_STORAGE_ACCOUNT="${var.storage_account_name}"
      export AZURE_STORAGE_SAS_TOKEN="${var.storage_sas_token}"
      
      # Download files using Azure CLI
      az storage blob download --container-name ${var.storage_container_name} --name webserver_setup.yml --file /home/${var.admin_username}/ansible/webserver_setup.yml
      az storage blob download --container-name ${var.storage_container_name} --name ansible.cfg --file /home/${var.admin_username}/ansible/ansible.cfg
      az storage blob download --container-name ${var.storage_container_name} --name templates/index.html.j2 --file /home/${var.admin_username}/ansible/templates/index.html.j2

      # Create a local inventory file for Ansible
      echo "localhost ansible_connection=local" > /home/${var.admin_username}/ansible/inventory

      # Add platform identification to the template
      sed -i 's/<\/div>/    <p><span class="label">Platform:<\/span> Azure<\/p>\n        <\/div>/g' /home/${var.admin_username}/ansible/templates/index.html.j2

      # Set proper permissions
      chmod -R 755 /home/${var.admin_username}/ansible
      chown -R ${var.admin_username}:${var.admin_username} /home/${var.admin_username}/ansible

      # Run the playbook
      cd /home/${var.admin_username}/ansible && ANSIBLE_CONFIG=/home/${var.admin_username}/ansible/ansible.cfg ansible-playbook webserver_setup.yml -i inventory

runcmd:
  - /var/lib/cloud/scripts/per-boot/install-and-configure.sh
EOF
  )
}


# Output the public IP
data "azurerm_public_ip" "ip" {
  name                = azurerm_public_ip.public_ip.name
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_linux_virtual_machine.vm]
}

output "public_ip" {
  value = data.azurerm_public_ip.ip.ip_address
}
