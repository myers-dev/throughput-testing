
module "vnet-peering01" {
  source = "../modules/vnet-peering"

  resource_group_name = var.resource_group_name
  location            = var.location

  peering = [{
    vnet_id                      = module.vnet["AZFPVNET"].vnet_id
    vnet_name                    = module.vnet["AZFPVNET"].vnet_name
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
    allow_gateway_transit        = false
    use_remote_gateways          = false
    },
    {
      vnet_id                      = module.vnet["spoke1"].vnet_id
      vnet_name                    = module.vnet["spoke1"].vnet_name
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
    vnet_id                      = module.vnet["AZFPVNET"].vnet_id
    vnet_name                    = module.vnet["AZFPVNET"].vnet_name
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
    allow_gateway_transit        = false
    use_remote_gateways          = false
    },
    {
      vnet_id                      = module.vnet["spoke2"].vnet_id
      vnet_name                    = module.vnet["spoke2"].vnet_name
      allow_virtual_network_access = true
      allow_forwarded_traffic      = true
      allow_gateway_transit        = false
      use_remote_gateways          = false
    }
  ]

}