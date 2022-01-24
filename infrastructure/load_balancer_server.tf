resource "azurerm_lb" "slb" {
  name                = "SLB"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "FE"
    availability_zone             = "Zone-Redundant"
    subnet_id                     = module.vnet["spoke2"].vnet_subnets[0]
    private_ip_address            = cidrhost(var.vnets["spoke2"].subnet_prefixes[0], 65534)
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
  }
}

resource "azurerm_lb_backend_address_pool" "slbpool" {
  loadbalancer_id = azurerm_lb.slb.id
  name            = "VMSSAP"
}

resource "azurerm_lb_probe" "http" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.slb.id
  name                = "port80"
  port                = 80
}

resource "azurerm_lb_probe" "https" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.slb.id
  name                = "port443"
  port                = 443
}

resource "azurerm_lb_rule" "http" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.slb.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "FE"
  probe_id                       = azurerm_lb_probe.http.id
  backend_address_pool_ids      = [ azurerm_lb_backend_address_pool.slbpool.id ]
}

resource "azurerm_lb_rule" "https" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.slb.id
  name                           = "https"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "FE"
  probe_id                       = azurerm_lb_probe.https.id
  backend_address_pool_ids      = [ azurerm_lb_backend_address_pool.slbpool.id ]
}