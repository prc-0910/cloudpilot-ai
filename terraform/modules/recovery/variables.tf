variable "prefix" {
  type        = string
  description = "Enterprise naming prefix."
}

variable "location" {
  type        = string
  description = "Primary Azure region."
}

variable "dr_location" {
  type        = string
  description = "DR Azure region."
}

variable "resource_group_name" {
  type        = string
  description = "Recovery resource group name."
}

variable "source_recovery_vault_name" {
  type        = string
  description = "Recovery Services Vault name."
}

variable "source_recovery_vault_id" {
  type        = string
  description = "Recovery Services Vault ID."
}

variable "source_vnet_id" {
  type        = string
  description = "Primary VNet mapped for ASR."
}

variable "target_vnet_id" {
  type        = string
  description = "DR VNet mapped for ASR."
}

variable "target_resource_group_id" {
  type        = string
  description = "Target DR resource group ID for migrated or failed-over VMs."
}

variable "vmware_process_server_name" {
  type        = string
  description = "Registered ASR VMware process server name. Documented for the runbook boundary."
}

variable "vmware_master_target_server_name" {
  type        = string
  description = "Registered ASR VMware master target server name. Documented for the runbook boundary."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags."
}
