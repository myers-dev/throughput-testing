resource "azurerm_public_ip" "azfwpip" {
  name                = "AZFWPIP"
  domain_name_label = "azfwpip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "azfw" {

  dns_servers = null

  private_ip_ranges = null

  name                = "AZFWP"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_tier = "Premium"
   
  zones = [ "1" , "2" , "3" ]
  
  firewall_policy_id = azurerm_firewall_policy.azfw-policy.id

  ip_configuration {
    name                 = "AZFWPIP"
    subnet_id            = module.vnet["AZFPVNET"].vnet_subnets[1]
    public_ip_address_id = azurerm_public_ip.azfwpip.id
  }

  tags = null
}

resource "azurerm_firewall_policy" "azfw-policy" {
  name                = "azfw-policy"
  resource_group_name = var.resource_group_name
  location            = var.location
}

# Firewall Policy Rules
resource "azurerm_firewall_policy_rule_collection_group" "azfw-policy" {
  name               = "azfw-policy"
  firewall_policy_id = azurerm_firewall_policy.azfw-policy.id
  priority           = 100

  network_rule_collection {
    name     = "network_rules1"
    priority = 200
    action   = "Allow"
    rule {
      name                  = "network_rule_collection1_rule1"
      protocols             = ["Any"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }
  }
}