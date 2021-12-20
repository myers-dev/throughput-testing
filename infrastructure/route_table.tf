resource "azurerm_route_table" "RT" {
  name                          = "rt"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = true

  depends_on = [
    azurerm_resource_group.rg
  ]

  route {
    name           = "default"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.azfw.ip_configuration[0].private_ip_address
  }

  route {
    name           = "custom1"
    address_prefix = "67.85.24.215/32"
    next_hop_type  = "Internet"
  }

  route {
    name           = "custom2"
    address_prefix = "68.198.24.244/32"
    next_hop_type  = "Internet"
  }


}

resource "azurerm_subnet_route_table_association" "RT" {
  for_each = var.vnets

  subnet_id      = module.vnet[each.key].vnet_subnets[0]
  route_table_id = azurerm_route_table.RT.id
}
