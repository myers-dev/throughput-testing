resource "azurerm_public_ip_prefix" "pfpip" {
  name                = "pfpip"
  resource_group_name = var.resource_group_name
  location = var.location
  prefix_length = 30
  sku = "Standard"
}


resource "azurerm_lb" "oslb" {
  name                = "OSLB"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "pfpip"
    #public_ip_address_id = azurerm_public_ip.pfpip.id
    public_ip_prefix_id = azurerm_public_ip_prefix.pfpip.id
  }
}

resource "azurerm_lb_backend_address_pool" "oslbpool" {
  loadbalancer_id = azurerm_lb.oslb.id
  name            = "OVMSSAP"
}

resource "azurerm_lb_outbound_rule" "orule" {
  resource_group_name = var.resource_group_name

  allocated_outbound_ports = 256

  loadbalancer_id         = azurerm_lb.oslb.id
  name                    = "OutboundRule"
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.oslbpool.id


  frontend_ip_configuration {
    name = "pfpip"
  }
}