resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "nsg" {
  source  = "Azure/network-security-group/azurerm"
  version = "3.6.0"

  resource_group_name = var.resource_group_name
  location            = var.location
  security_group_name = var.security_group_name

  custom_rules = var.custom_rules

  tags = var.tags

  # to overcome an error of non-existent RG
  depends_on = [
    azurerm_resource_group.rg
  ]
}

module "vnet" {
  source  = "Azure/vnet/azurerm"
  version = "2.5.0"

  count = length(var.vnets)

  resource_group_name = var.resource_group_name
  vnet_name           = "${var.vnets[count.index]["name"]}-vnet"

  address_space = var.vnets[count.index]["address_space"]

  subnet_names    = var.vnets[count.index]["subnet_names"]
  subnet_prefixes = var.vnets[count.index]["subnet_prefixes"]

  subnet_enforce_private_link_endpoint_network_policies = var.vnets[count.index]["enforce_private_link_endpoint_network_policies"]
  subnet_enforce_private_link_service_network_policies  = var.vnets[count.index]["enforce_private_link_service_network_policies"]

  nsg_ids = {
    "default" = module.nsg.network_security_group_id
  }

  tags          = var.tags
  vnet_location = var.location

  # to overcome an error of non-existent RG
  depends_on = [
    azurerm_resource_group.rg
  ]
}
