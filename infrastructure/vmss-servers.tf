data "template_file" "server" {

  template = "${file("scripts/server.txt")}"
  vars = {
    CONNECTION_STR = azurerm_servicebus_namespace_authorization_rule.this.primary_connection_string 
    QUEUE_NAME = azurerm_servicebus_queue.this.name
  }
}


resource "azurerm_linux_virtual_machine_scale_set" "servers" {

  for_each = { 
               "spoke2" = var.vnets["spoke2"] 
              }

  name                = "servers${each.key}"

  location            = var.location
  resource_group_name = var.resource_group_name

  sku                 = "Standard_D4_v4" # "Standard_DS3_v2" # "Standard_D3_v2" # "Standard_F2"

  instances           = var.vmssscale
  admin_username      = data.azurerm_key_vault_secret.keyvault-username.value 

  custom_data = base64encode(data.template_file.server.rendered)

  admin_ssh_key {
    username   = data.azurerm_key_vault_secret.keyvault-username.value
    public_key = data.azurerm_ssh_public_key.sshkey.public_key
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "nic"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = module.vnet[each.key].vnet_subnets[0]
    }
  }
}