location = "centralus"

resource_group_name = "AZFP"

tags = {
  Terraform   = "true"
  Environment = "dev"
}

lock_level = ""

security_group_name = "nsg"

vnets = {
  "AZFPVNET" = {
    address_space   = ["10.0.0.0/16"]
    subnet_names    = ["default", "AzureFirewallSubnet"]
    subnet_prefixes = ["10.0.1.0/24", "10.0.0.0/24"]
    enforce_private_link_endpoint_network_policies = {
      default             = false # "privateEndpointNetworkPolicies": "Disabled=true Enabled=false",
      AzureFirewallSubnet = false # "privateEndpointNetworkPolicies": "Disabled=true Enabled=false"
    }
    enforce_private_link_service_network_policies = {
      default             = false # "privateEndpointNetworkPolicies": "Disabled=true Enabled=false",
      AzureFirewallSubnet = false # "privateEndpointNetworkPolicies": "Disabled=true Enabled=false"
    }
  },
  "spoke1" = {
    address_space   = ["10.2.0.0/16"]
    subnet_names    = ["default"]
    subnet_prefixes = ["10.2.0.0/16"]
    enforce_private_link_endpoint_network_policies = {
      default = true # "privateEndpointNetworkPolicies": "Disabled=true Enabled=false"
    }
    enforce_private_link_service_network_policies = {
      default = true # "privateLinkServiceNetworkPolicies": "Disabled=true Enabled=false"
    }
  },
  "spoke2" = {
    address_space   = ["10.1.0.0/16"]
    subnet_names    = ["default"]
    subnet_prefixes = ["10.1.0.0/16"]
    enforce_private_link_endpoint_network_policies = {
      default = true # "privateEndpointNetworkPolicies": "Disabled=true Enabled=false",
    }
    enforce_private_link_service_network_policies = {
      default = true # "privateLinkServiceNetworkPolicies": "Disabled=true Enabled=false",
    }
  }
}

vmssscale = 0

idps = "Off"




