resource "azurerm_route_table" "RT" {
  name                          = "rt"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = true

  depends_on = [
    azurerm_resource_group.rg
  ]

  route {
    name                   = "default"
    address_prefix         = "10.0.0.0/8"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.azfw.ip_configuration[0].private_ip_address
  }

}

resource "azurerm_subnet_route_table_association" "RT" {
  for_each = var.vnets

  subnet_id      = module.vnet[each.key].vnet_subnets[0]
  route_table_id = azurerm_route_table.RT.id
}
