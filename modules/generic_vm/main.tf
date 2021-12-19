
resource "azurerm_network_interface" "nic" {

  count = length(var.subnet_ids)

  name                = "${var.name}-nic-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  enable_ip_forwarding = var.enable_ip_forwarding

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_ids[count.index]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = count.index == 0 ? var.public_ip_address_id : ""
  }
}

resource "azurerm_virtual_machine" "generic_vm" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  vm_size             = var.vm_size

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  primary_network_interface_id = azurerm_network_interface.nic[0].id
  network_interface_ids = azurerm_network_interface.nic.*.id

  zones = [ var.zone ]

  os_profile {
    computer_name = var.name
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = var.disable_password_authentication
    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = var.ssh_key_data
    }
  }

  storage_image_reference {
    publisher = var.storage_image_reference.publisher
    offer     = var.storage_image_reference.offer
    sku       = var.storage_image_reference.sku
    version   = var.storage_image_reference.version
  }

  plan {
    name = var.plan.name
    publisher = var.plan.publisher
    product = var.plan.product
  }

  storage_os_disk {
    name              = "${var.name}osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }


}

