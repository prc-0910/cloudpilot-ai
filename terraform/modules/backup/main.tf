resource "azurerm_recovery_services_vault" "this" {
  name                = "rsv-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  storage_mode_type   = "GeoRedundant"
  soft_delete_enabled = true
  immutability        = "Unlocked"
  tags                = var.tags
}

resource "azurerm_backup_policy_vm" "daily" {
  name                = "bkpol-${var.prefix}-vm-daily"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.this.name
  timezone            = "UTC"

  backup {
    frequency = "Daily"
    time      = var.backup_time
  }

  retention_daily {
    count = var.retention_daily_count
  }

  retention_weekly {
    count    = var.retention_weekly_count
    weekdays = ["Sunday"]
  }
}

data "azurerm_monitor_diagnostic_categories" "vault" {
  resource_id = azurerm_recovery_services_vault.this.id
}

resource "azurerm_monitor_diagnostic_setting" "vault" {
  name                           = "diag-${var.prefix}-rsv"
  target_resource_id             = azurerm_recovery_services_vault.this.id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = "Dedicated"

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.vault.log_category_types
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.vault.metrics
    content {
      category = metric.value
      enabled  = true
    }
  }
}
