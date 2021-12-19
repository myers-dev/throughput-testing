# resource "azurerm_marketplace_agreement" "paloalto" {
#     publisher ="paloaltonetworks"
#     offer     = "vmseries-flex"
#     plan = "bundle2"
# }

locals {
  subnet_ids = compact([for subnet_id in module.vnet[0].vnet_subnets : trimsuffix(subnet_id, "AzureFirewallSubnet") == subnet_id ? subnet_id : ""])
}

module "PA" {
  source = "../modules/generic_vm"

  count = var.pa_scale

  resource_group_name = var.resource_group_name
  location            = var.location

  name = "PA${count.index}"

  #subnet_ids = module.vnet[0].vnet_subnets
  subnet_ids = local.subnet_ids

  enable_ip_forwarding = true

  public_ip_address_id = azurerm_public_ip.pa-pip[count.index].id

  vm_size = "Standard_D3_v2"

  zone = count.index % 3 + 1

  storage_image_reference = {
    publisher = "paloaltonetworks"
    offer = "vmseries-flex"
    sku = "byol"
    version = "latest"
  }

  plan = {
    name = "byol"
    publisher = "paloaltonetworks"
    product = "vmseries-flex"
  }


  # storage_image_reference = {
  #   publisher = "paloaltonetworks"
  #   offer     = "vmseries-flex"
  #   sku       = "bundle2"
  #   version   = "latest"
  # }

  # plan = {
  #   name      = "bundle2"
  #   publisher = "paloaltonetworks"
  #   product   = "vmseries-flex"
  # }


  disable_password_authentication = false
  admin_username                  = data.azurerm_key_vault_secret.keyvault-username.value
  admin_password                  = data.azurerm_key_vault_secret.keyvault-password.value
  ssh_key_data                    = data.azurerm_ssh_public_key.sshkey.public_key

  # to overcome an error of non-existent RG
  depends_on = [
    azurerm_resource_group.rg
  ]

}