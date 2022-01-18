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

  custom_rules = [
  {
    name                   = "R100"
    priority               = 100
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "tcp"
    source_port_range      = "*"
    destination_port_range = "22,80,443"
    source_address_prefix  = data.external.my_ip.result.my_ip
    description            = "MGMT"
  }
]

  tags = var.tags

  # to overcome an error of non-existent RG
  depends_on = [
    azurerm_resource_group.rg
  ]
}


module "vnet" {
  source  = "Azure/vnet/azurerm"
  version = "2.5.0"

  for_each = var.vnets

  resource_group_name = var.resource_group_name
  vnet_name           = each.key

  address_space = each.value.address_space

  subnet_names    = each.value.subnet_names
  subnet_prefixes = each.value.subnet_prefixes

  subnet_enforce_private_link_endpoint_network_policies = each.value.enforce_private_link_endpoint_network_policies
  subnet_enforce_private_link_service_network_policies  = each.value.enforce_private_link_service_network_policies

  #nsg_ids = {
  #  "default" = module.nsg.network_security_group_id
  #}

  tags          = var.tags
  vnet_location = var.location

  # to overcome an error of non-existent RG
  depends_on = [
    azurerm_resource_group.rg
  ]
}

resource "azurerm_subnet_network_security_group_association" "this" {

  for_each = var.vnets

  subnet_id                 = module.vnet[each.key].vnet_subnets[0]
  network_security_group_id = module.nsg.network_security_group_id
}
