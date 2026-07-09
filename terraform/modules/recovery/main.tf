resource "azurerm_site_recovery_fabric" "primary" {
  name                = "asr-fabric-${var.prefix}-primary"
  resource_group_name = var.resource_group_name
  recovery_vault_name = var.source_recovery_vault_name
  location            = var.location
}

resource "azurerm_site_recovery_fabric" "secondary" {
  name                = "asr-fabric-${var.prefix}-secondary"
  resource_group_name = var.resource_group_name
  recovery_vault_name = var.source_recovery_vault_name
  location            = var.dr_location
}

resource "azurerm_site_recovery_protection_container" "primary" {
  name                 = "asr-pc-${var.prefix}-primary"
  resource_group_name  = var.resource_group_name
  recovery_vault_name  = var.source_recovery_vault_name
  recovery_fabric_name = azurerm_site_recovery_fabric.primary.name
}

resource "azurerm_site_recovery_protection_container" "secondary" {
  name                 = "asr-pc-${var.prefix}-secondary"
  resource_group_name  = var.resource_group_name
  recovery_vault_name  = var.source_recovery_vault_name
  recovery_fabric_name = azurerm_site_recovery_fabric.secondary.name
}

resource "azurerm_site_recovery_replication_policy" "this" {
  name                                                 = "asrpol-${var.prefix}"
  resource_group_name                                  = var.resource_group_name
  recovery_vault_name                                  = var.source_recovery_vault_name
  recovery_point_retention_in_minutes                  = 24 * 60
  application_consistent_snapshot_frequency_in_minutes = 4 * 60
}

resource "azurerm_site_recovery_protection_container_mapping" "primary_to_secondary" {
  name                                      = "asrmap-${var.prefix}-pc-primary-secondary"
  resource_group_name                       = var.resource_group_name
  recovery_vault_name                       = var.source_recovery_vault_name
  recovery_fabric_name                      = azurerm_site_recovery_fabric.primary.name
  recovery_source_protection_container_name = azurerm_site_recovery_protection_container.primary.name
  recovery_target_protection_container_id   = azurerm_site_recovery_protection_container.secondary.id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.this.id
}

resource "azurerm_site_recovery_network_mapping" "primary_to_secondary" {
  name                        = "asrmap-${var.prefix}-network-primary-secondary"
  resource_group_name         = var.resource_group_name
  recovery_vault_name         = var.source_recovery_vault_name
  source_recovery_fabric_name = azurerm_site_recovery_fabric.primary.name
  target_recovery_fabric_name = azurerm_site_recovery_fabric.secondary.name
  source_network_id           = var.source_vnet_id
  target_network_id           = var.target_vnet_id
}

data "azurerm_monitor_diagnostic_categories" "vault" {
  resource_id = var.source_recovery_vault_id
}

resource "azurerm_monitor_diagnostic_setting" "asr_vault" {
  name                           = "diag-${var.prefix}-asr"
  target_resource_id             = var.source_recovery_vault_id
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
