# output "Hub_Linux_public_ip" {
#   value = azurerm_public_ip.pip["AZFPVNET"].ip_address
# }

output "Spoke1_Linux_public_ip" {
  value = azurerm_public_ip.pip["spoke1"].ip_address
}

output "Spoke2_Linux_public_ip" {
  value = azurerm_public_ip.pip["spoke2"].ip_address
}

output "rg" {
  value = var.resource_group_name
}
