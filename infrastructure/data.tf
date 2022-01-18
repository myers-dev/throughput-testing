locals {
  kvname = "cs-keystore-pm"
}

data "azurerm_key_vault_secret" "keyvault-username" {
  name         = "adminusername"
  key_vault_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.KeyVault/vaults/${local.kvname}"
}

data "azurerm_key_vault_secret" "keyvault-password" {
  name         = "adminpassword"
  key_vault_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.KeyVault/vaults/${local.kvname}"
}

data "azurerm_ssh_public_key" "sshkey" {
  name                = "desktop"
  resource_group_name = "${var.resource_group_name}"
}

data "azurerm_key_vault_secret" "sharedkey" {
  name         = "sharedkey"
  key_vault_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.KeyVault/vaults/${local.kvname}"
}

data "azurerm_subscription" "current" {
}

data "external" "my_ip" {
  program   = [
    "/bin/bash", "scripts/my_ip.sh"
  ]
}