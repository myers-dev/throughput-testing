resource "azurerm_public_ip" "azfwpip" {
  name                = "azfw${random_id.id.hex}"
  domain_name_label   = "azfw${random_id.id.hex}"
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

  zones = ["1", "2", "3"]

  firewall_policy_id = azurerm_firewall_policy.azfw-policy.id

  ip_configuration {
    name                 = "AZFWPIP"
    subnet_id            = module.vnet["AZFPVNET"].vnet_subnets[1]
    public_ip_address_id = azurerm_public_ip.azfwpip.id
  }

  tags = null
}

resource "azurerm_firewall_policy" "azfw-policy" {
  name = "azfw-policy"

  sku = "Premium"

  resource_group_name = var.resource_group_name
  location            = var.location

  intrusion_detection {
    #mode = "Alert"
    #mode = "Deny"
    mode = "Off"
  }

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
      name                  = "iperf3"
      protocols             = ["Any"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["5201"]
    }
    rule {
      name                  = "http"
      protocols             = ["Any"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["80"]
    }
    rule {
      name                  = "https"
      protocols             = ["Any"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["443"]
    }
    rule {
      name                  = "ntttcp5000"
      protocols             = ["Any"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["5000-6000"]
    }
    rule {
      name                  = "ethr9999"
      protocols             = ["Any"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["9999"]
    }
    rule {
      name                  = "icmp"
      protocols             = ["ICMP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }
  }
  #
  #   application_rule_collection {
  #    name     = "app_rule_collection1"
  #    priority = 300
  #    action   = "Deny"
  #    rule {
  #      name = "app_rule_collection1_rule1"
  #      protocols {
  #        type = "Http"
  #        port = 80
  #      }
  #      protocols {
  #        type = "Https"
  #        port = 443
  #      }
  #      source_addresses  = ["*"]
  #      destination_fqdns = ["*"]
  #    }
  #  }



}