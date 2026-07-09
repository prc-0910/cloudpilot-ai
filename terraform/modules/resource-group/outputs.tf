output "network_resource_group_name" {
  value = azurerm_resource_group.network.name
}

output "management_resource_group_name" {
  value = azurerm_resource_group.management.name
}

output "security_resource_group_name" {
  value = azurerm_resource_group.security.name
}

output "recovery_resource_group_name" {
  value = azurerm_resource_group.recovery.name
}

output "dr_resource_group_id" {
  value = azurerm_resource_group.dr.id
}

output "resource_group_names" {
  value = {
    network    = azurerm_resource_group.network.name
    management = azurerm_resource_group.management.name
    security   = azurerm_resource_group.security.name
    recovery   = azurerm_resource_group.recovery.name
    dr         = azurerm_resource_group.dr.name
  }
}
