resource "azurerm_log_analytics_workspace" "this" {
  name                = "law-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  daily_quota_gb      = 20
  tags                = var.tags
}

resource "azurerm_monitor_action_group" "operations" {
  name                = "ag-${var.prefix}-ops"
  resource_group_name = var.resource_group_name
  short_name          = "ops"
  tags                = var.tags

  email_receiver {
    name                    = var.action_group_email_name
    email_address           = var.action_group_email_address
    use_common_alert_schema = true
  }
}

data "azurerm_monitor_diagnostic_categories" "targets" {
  for_each    = toset(var.diagnostic_target_ids)
  resource_id = each.value
}

resource "azurerm_monitor_diagnostic_setting" "targets" {
  for_each = toset(var.diagnostic_target_ids)

  name                           = "diag-${var.prefix}"
  target_resource_id             = each.value
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.this.id
  log_analytics_destination_type = "Dedicated"

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.targets[each.value].log_category_types
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.targets[each.value].metrics
    content {
      category = metric.value
      enabled  = true
    }
  }
}

resource "azurerm_monitor_metric_alert" "firewall_health" {
  name                = "ma-${var.prefix}-firewall-health"
  resource_group_name = var.resource_group_name
  scopes              = [for id in var.diagnostic_target_ids : id if can(regex("/Microsoft.Network/azureFirewalls/", id))]
  description         = "Alert when Azure Firewall health drops below healthy threshold."
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = length([for id in var.diagnostic_target_ids : id if can(regex("/Microsoft.Network/azureFirewalls/", id))]) > 0
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Network/azureFirewalls"
    metric_name      = "FirewallHealth"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 90
  }

  action {
    action_group_id = azurerm_monitor_action_group.operations.id
  }
}
