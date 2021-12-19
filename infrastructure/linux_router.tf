locals {
  custom_data = <<-CUSTOM_DATA
      #!/bin/bash
      apt-get update -y
      #apt-get upgrade -y
      sysctl -w net.ipv4.ip_forward=1
      sysctl -p
      apt-get install nginx -y
      apt-get install software-properties-common -y
      add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu groovy universe"
      apt-get update -y
      apt-get install net-tools -y
      apt-get install iputils-ping -y
      apt-get install inetutils-traceroute -y
      apt-get install iproute2 -y
      apt-get install wrk -y
      CUSTOM_DATA
}

resource "azurerm_network_interface" "linuxrouternic" {

  name                = "linuxrouternic"
  location            = var.location
  resource_group_name = var.resource_group_name

  enable_accelerated_networking = true
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet[0].vnet_subnets[1]
    private_ip_address_allocation = "Dynamic"
#    public_ip_address_id = azurerm_public_ip.linuxrouterpip.id
  }
}

# resource "azurerm_public_ip" "linuxrouterpip" {

#   name                = "linuxrouter-pip"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   allocation_method   = "Static"
#   sku                 = "Standard"

#   tags = var.tags
# }

resource "azurerm_storage_account" "linuxrouterboot_diagnostic" {

  name                = "linuxrouterstorage"
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "linuxrouter" {

  name                = "linuxrouter"
  resource_group_name = var.resource_group_name
  location            = var.location
  #size                = "Standard_DS4_v2"
  size                = "Standard_D3_v2"
  admin_username      = data.azurerm_key_vault_secret.keyvault-username.value
  admin_password      = data.azurerm_key_vault_secret.keyvault-password.value

  custom_data = base64encode(local.custom_data)

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.linuxrouternic.id,
  ]

  admin_ssh_key {
    username   = data.azurerm_key_vault_secret.keyvault-username.value
    public_key = data.azurerm_ssh_public_key.sshkey.public_key
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.linuxrouterboot_diagnostic.primary_blob_endpoint
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

