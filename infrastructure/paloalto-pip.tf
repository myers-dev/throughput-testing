#
# Public IP for PA
#

resource "random_id" "id" {
  byte_length = 8
}

resource "azurerm_public_ip" "pa-pip" {
  count               = var.pa_scale
  name                = "pa-pip${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  domain_name_label = "paloalto${random_id.id.hex}"

  # to overcome an error of non-existent RG
  depends_on = [
    azurerm_resource_group.rg
  ]
}

