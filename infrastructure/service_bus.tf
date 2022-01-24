resource "azurerm_servicebus_namespace" "this" {
  name = "tt${random_id.id.hex}"

  location            = var.location
  resource_group_name = var.resource_group_name

  sku = "Standard"

}

resource "azurerm_servicebus_queue" "this" {
  name                = "ipserverip"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.this.name

  #auto_delete_on_idle = "PT10M"
  default_message_ttl = "PT10M"

  enable_partitioning = true
}

resource "azurerm_servicebus_namespace_authorization_rule" "this" {

  name                = "authorization"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.this.name

  listen = true
  send   = true
  manage = false
}