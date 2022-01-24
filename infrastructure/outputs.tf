output "resource_group_name" {
  value = var.resource_group_name
}

output "Spoke1_Linux_public_ip" {
  value = azurerm_public_ip.pip["spoke1"].ip_address
}

output "Spoke2_Linux_public_ip" {
  value = azurerm_public_ip.pip["spoke2"].ip_address
}

output "AZFW_Linux_public_ip" {
  value = azurerm_public_ip.pip["AZFPVNET"].ip_address
}

output "rg" {
  value = var.resource_group_name
}

output "my_ip" {
  value = data.external.my_ip.result.my_ip
}

output "clients" {
  value = azurerm_linux_virtual_machine_scale_set.clients["spoke1"].name
}


output "servers" {
  value = azurerm_linux_virtual_machine_scale_set.servers["spoke2"].name
}

output "subnet1_id" {
  value = module.vnet["spoke1"].vnet_subnets[0]
}


output "subnet2_id" {
  value = module.vnet["spoke2"].vnet_subnets[0]
}


output "vnet1_id" {
  value = module.vnet["spoke1"].vnet_id
}


output "vnet2_id" {
  value = module.vnet["spoke2"].vnet_id
}