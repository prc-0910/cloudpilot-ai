output "resource_group_names" {
  description = "Resource groups created for the landing zone workload."
  value       = module.resource_groups.resource_group_names
}

output "hub_vnet_id" {
  description = "Hub virtual network resource ID."
  value       = module.network.hub_vnet_id
}

output "spoke_vnet_ids" {
  description = "Spoke virtual network resource IDs."
  value       = module.network.spoke_vnet_ids
}

output "firewall_private_ip" {
  description = "Azure Firewall private IP used as the next hop for spoke routes."
  value       = module.firewall.firewall_private_ip
}

output "bastion_fqdn" {
  description = "Azure Bastion FQDN."
  value       = module.network.bastion_fqdn
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace resource ID."
  value       = module.monitoring.log_analytics_workspace_id
}

output "recovery_services_vault_id" {
  description = "Recovery Services Vault resource ID."
  value       = module.backup.recovery_services_vault_id
}

output "backup_policy_id" {
  description = "Azure VM backup policy resource ID."
  value       = module.backup.vm_backup_policy_id
}

output "key_vault_uri" {
  description = "Key Vault URI."
  value       = module.security.key_vault_uri
}
