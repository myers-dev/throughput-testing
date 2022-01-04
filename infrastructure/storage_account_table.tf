resource "azurerm_storage_account" "tresult" {
  name                     = "ttresult"
  resource_group_name = var.resource_group_name
  location            = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  shared_access_key_enabled = true 

}

resource "azurerm_storage_table" "tresult" {
  name                 = "stats"
  storage_account_name = azurerm_storage_account.tresult.name
}