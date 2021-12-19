output "PA_public_ip" {
  value = azurerm_public_ip.pa-pip.*.ip_address
}

output "Linux_public_ip" {
  value = azurerm_public_ip.pip.*.ip_address
}

output "subnet1_id" {
  value = module.vnet[1].vnet_subnets[0]
}

output "subnet2_id" {
  value = module.vnet[2].vnet_subnets[0]
}

output "rg" {
  value = var.resource_group_name
}

output "linux_router_private_ip" {
  value = azurerm_network_interface.linuxrouternic.private_ip_address
}

# output "linux_router_public_ip" {
#   value = azurerm_public_ip.linuxrouterpip.ip_address
# }

output "vnet2_id" {
  value = module.vnet[2].vnet_id
}