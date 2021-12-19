resource "azurerm_route_table" "RT" {
  name                          = "no_bgp_rt"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = true

  depends_on = [
    azurerm_resource_group.rg
  ]

  route {
     name                   = "Spoke2Spoke"
     address_prefix         = "10.0.0.0/8"
     next_hop_type          = "VirtualAppliance"
     #next_hop_in_ip_address = module.PA[0].azurerm_network_interface_private_ip_address[1]
     #next_hop_in_ip_address = azurerm_network_interface.linuxrouternic.private_ip_address
     next_hop_in_ip_address = azurerm_firewall.azfw[0].ip_configuration[0].private_ip_address
  }

  route {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "Internet"
  }

}

resource "azurerm_subnet_route_table_association" "RT" {
  for_each = {
    vnet1 = 1
    vnet2 = 2
  }
  subnet_id      = module.vnet[each.value].vnet_subnets[0]
  route_table_id = azurerm_route_table.RT.id
}
