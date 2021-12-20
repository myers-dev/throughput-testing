

resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown-linux" {

  for_each = azurerm_linux_virtual_machine.vm

  virtual_machine_id = each.value.id
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