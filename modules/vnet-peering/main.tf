# enable global peering between the two virtual network
resource "azurerm_virtual_network_peering" "peering12" {
  name                         = "peering-from-${var.peering[0].vnet_name}-to-${var.peering[1].vnet_name}"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = var.peering[0].vnet_name
  remote_virtual_network_id    = var.peering[1].vnet_id
  allow_virtual_network_access = var.peering[0].allow_virtual_network_access
  allow_forwarded_traffic      = var.peering[0].allow_forwarded_traffic
  allow_gateway_transit        = var.peering[0].allow_gateway_transit
  use_remote_gateways          = var.peering[0].use_remote_gateways
}

resource "azurerm_virtual_network_peering" "peering21" {
  name                         = "peering-from-${var.peering[1].vnet_name}-to-${var.peering[0].vnet_name}"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = var.peering[1].vnet_name
  remote_virtual_network_id    = var.peering[0].vnet_id
  allow_virtual_network_access = var.peering[1].allow_virtual_network_access
  allow_forwarded_traffic      = var.peering[1].allow_forwarded_traffic
  allow_gateway_transit        = var.peering[1].allow_gateway_transit
  use_remote_gateways          = var.peering[1].use_remote_gateways
}
