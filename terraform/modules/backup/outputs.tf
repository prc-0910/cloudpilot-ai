output "recovery_services_vault_id" {
  value = azurerm_recovery_services_vault.this.id
}

output "recovery_services_vault_name" {
  value = azurerm_recovery_services_vault.this.name
}

output "vm_backup_policy_id" {
  value = azurerm_backup_policy_vm.daily.id
}
