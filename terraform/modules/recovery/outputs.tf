output "replication_policy_id" {
  value = azurerm_site_recovery_replication_policy.this.id
}

output "network_mapping_id" {
  value = azurerm_site_recovery_network_mapping.primary_to_secondary.id
}

output "target_resource_group_id" {
  value = var.target_resource_group_id
}

output "vmware_registration_reference" {
  value = {
    process_server_name       = var.vmware_process_server_name
    master_target_server_name = var.vmware_master_target_server_name
  }
}
