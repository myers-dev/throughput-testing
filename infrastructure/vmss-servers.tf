data "template_file" "server" {

  template = file("scripts/server.txt")
  vars = {
    CONNECTION_STR = azurerm_servicebus_namespace_authorization_rule.this.primary_connection_string
    QUEUE_NAME     = azurerm_servicebus_queue.this.name
  }
}


resource "azurerm_linux_virtual_machine_scale_set" "servers" {

  for_each = {
    "spoke2" = var.vnets["spoke2"]
  }

  name = "servers${each.key}"

  location            = var.location
  resource_group_name = var.resource_group_name

  sku = var.vmss_size 

  instances      = var.vmssscale
  admin_username = data.azurerm_key_vault_secret.keyvault-username.value

  upgrade_mode           = "Automatic"
  single_placement_group = false

  zone_balance = false
  #zones = [1,2,3]
  zones = [1]

  custom_data = base64encode(data.template_file.server.rendered)

  #health_probe_id = azurerm_lb_probe.http.id

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
    name                          = "nic"
    primary                       = true
    enable_accelerated_networking = "true"

    ip_configuration {

      name      = "internal"
      primary   = true
      subnet_id = module.vnet[each.key].vnet_subnets[0]

      #load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.slbpool.id, azurerm_lb_backend_address_pool.oslbpool.id ]

    }
  }
}