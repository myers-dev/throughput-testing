location = "centralus"

resource_group_name = "NVAConnections"

tags = {
  Terraform   = "true"
  Environment = "dev"
}

lock_level = ""

security_group_name = "nsg"

custom_rules = [
  {
    name                   = "TH1"
    priority               = 300
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "tcp"
    source_port_range      = "*"
    destination_port_range = "22,80,443"
    source_address_prefix  = "68.198.19.100/32"
    description            = "description-myssh"
  },
  {
    name                   = "TH2"
    priority               = 301
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "tcp"
    source_port_range      = "*"
    destination_port_range = "22,80,443"
    source_address_prefix  = "67.85.28.42/32"
    description            = "description-myssh"
  },
]

vnets = [
  {
    name            = "hub"
    address_space   = ["10.2.0.0/16"]
    subnet_names    = ["default", "trusted", "untrusted", "AzureFirewallSubnet"]
    subnet_prefixes = ["10.2.0.0/24", "10.2.1.0/24", "10.2.2.0/24" , "10.2.3.0/24"]
    enforce_private_link_endpoint_network_policies = {
      default    = true # "privateEndpointNetworkPolicies": "Disabled=true Enabled=false",
      trusted    = true # "privateEndpointNetworkPolicies": "Disabled=true Enabled=false",
      untrusted  = true # "privateEndpointNetworkPolicies": "Disabled=true Enabled=false",
      AzureFirewallSubnet  = true # "privateEndpointNetworkPolicies": "Disabled=true Enabled=false"
    }
    enforce_private_link_service_network_policies = {
      default    = true # "privateEndpointNetworkPolicies": "Disabled=true Enabled=false",
      trusted    = true # "privateEndpointNetworkPolicies": "Disabled=true Enabled=false",
      untrusted  = true # "privateEndpointNetworkPolicies": "Disabled=true Enabled=false",
      AzureFirewallSubnet  = true # "privateEndpointNetworkPolicies": "Disabled=true Enabled=false"
    }
  },
  {
    name            = "spoke1"
    address_space   = ["10.0.0.0/16"]
    subnet_names    = ["default"]
    subnet_prefixes = ["10.0.0.0/16"]
    enforce_private_link_endpoint_network_policies = {
      default = true # "privateEndpointNetworkPolicies": "Disabled=true Enabled=false"
    }
    enforce_private_link_service_network_policies = {
      default = true # "privateLinkServiceNetworkPolicies": "Disabled=true Enabled=false"
    }
  },
  {
    name            = "spoke2"
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
]

pa_scale = 1



