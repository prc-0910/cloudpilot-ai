resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_key_vault" "this" {
  name                          = substr(replace("kv-${var.prefix}-${random_string.suffix.result}", "-", ""), 0, 24)
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = var.tenant_id
  sku_name                      = "premium"
  enabled_for_disk_encryption   = true
  purge_protection_enabled      = true
  soft_delete_retention_days    = 90
  public_network_access_enabled = !var.create_key_vault_private_endpoint
  enable_rbac_authorization     = true
  tags                          = var.tags

  network_acls {
    bypass         = "AzureServices"
    default_action = var.create_key_vault_private_endpoint ? "Deny" : "Allow"
  }
}

resource "azurerm_role_assignment" "current_user_key_vault_admin" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.current_object_id
}

resource "azurerm_private_dns_zone" "key_vault" {
  count               = var.create_key_vault_private_endpoint ? 1 : 0
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  count                 = var.create_key_vault_private_endpoint ? 1 : 0
  name                  = "pdnslink-${var.prefix}-kv-hub"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault[0].name
  virtual_network_id    = var.private_dns_zone_vnet_link_id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_endpoint" "key_vault" {
  count               = var.create_key_vault_private_endpoint ? 1 : 0
  name                = "pe-${var.prefix}-kv"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-${var.prefix}-kv"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.key_vault[0].id]
  }
}

data "azurerm_monitor_diagnostic_categories" "key_vault" {
  resource_id = azurerm_key_vault.this.id
}

resource "azurerm_monitor_diagnostic_setting" "key_vault" {
  name                           = "diag-${var.prefix}-kv"
  target_resource_id             = azurerm_key_vault.this.id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = "Dedicated"

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.key_vault.log_category_types
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.key_vault.metrics
    content {
      category = metric.value
      enabled  = true
    }
  }
}
