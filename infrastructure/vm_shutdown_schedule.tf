resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown-pa" {

  count = var.pa_scale

  virtual_machine_id = module.PA[count.index].azurerm_virtual_machine_id
  location           = var.location
  enabled            = true

  daily_recurrence_time = "2300"
  timezone              = "Eastern Standard Time"

  notification_settings {
    enabled         = false
    time_in_minutes = "60"
    webhook_url     = "https://sample-webhook-url.example.com"
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown-linux" {

  count = length(azurerm_linux_virtual_machine.vm.*.id)

  virtual_machine_id = azurerm_linux_virtual_machine.vm[count.index].id
  location           = var.location
  enabled            = true

  daily_recurrence_time = "2300"
  timezone              = "Eastern Standard Time"

  notification_settings {
    enabled         = false
    time_in_minutes = "60"
    webhook_url     = "https://sample-webhook-url.example.com"
  }
}