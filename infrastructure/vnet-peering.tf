
module "vnet-peering01" {
  source = "../modules/vnet-peering"

  resource_group_name = var.resource_group_name
  location            = var.location

  peering = [{
    vnet_id                      = module.vnet[0].vnet_id
    vnet_name                    = module.vnet[0].vnet_name
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
    allow_gateway_transit        = false
    use_remote_gateways          = false
    },
    {
      vnet_id                      = module.vnet[1].vnet_id
      vnet_name                    = module.vnet[1].vnet_name
      allow_virtual_network_access = true
      allow_forwarded_traffic      = true
      allow_gateway_transit        = false
      use_remote_gateways          = false
    }
  ]

}


module "vnet-peering02" {
  source = "../modules/vnet-peering"

  resource_group_name = var.resource_group_name
  location            = var.location

  peering = [{
    vnet_id                      = module.vnet[0].vnet_id
    vnet_name                    = module.vnet[0].vnet_name
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
    allow_gateway_transit        = false
    use_remote_gateways          = false
    },
    {
      vnet_id                      = module.vnet[2].vnet_id
      vnet_name                    = module.vnet[2].vnet_name
      allow_virtual_network_access = true
      allow_forwarded_traffic      = true
      allow_gateway_transit        = false
      use_remote_gateways          = false
    }
  ]

}