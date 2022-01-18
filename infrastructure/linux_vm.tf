locals {
  vm_loc = { "spoke1" = var.vnets["spoke1"], 
               "spoke2" = var.vnets["spoke2"],
               "AZFPVNET"    = var.vnets["AZFPVNET"] 
           }
} 

resource "azurerm_network_interface" "nic" {

  for_each = local.vm_loc
  #for_each = {}
  #for_each = var.vnets

  name                = "${each.key}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  enable_accelerated_networking = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet[each.key].vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[each.key].id
  }
}

resource "azurerm_public_ip" "pip" {

  for_each = local.vm_loc
  #for_each = {}
  #for_each = var.vnets

  name                = "${each.key}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_storage_account" "boot_diagnostic" {

  for_each = local.vm_loc
  #for_each = var.vnets

  name                = lower("${random_id.id.hex}${each.key}")
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = var.tags
}
resource "azurerm_linux_virtual_machine" "vm" {

  for_each = local.vm_loc

  name                = "${each.key}-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_F2" # "Standard_DS5_v2" #"Standard_D48_v3" , "Standard_F2" , Standard_DS4_v2 , Standard_DS5_v2 , Standard_DS4_v2
  admin_username      = data.azurerm_key_vault_secret.keyvault-username.value
  admin_password      = data.azurerm_key_vault_secret.keyvault-password.value

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id,
  ]

  admin_ssh_key {
    username   = data.azurerm_key_vault_secret.keyvault-username.value
    public_key = data.azurerm_ssh_public_key.sshkey.public_key
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.boot_diagnostic[each.key].primary_blob_endpoint
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no /home/andrew/.ssh/id_rsa azureadmin@${azurerm_public_ip.pip[each.key].ip_address}:.ssh/"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
