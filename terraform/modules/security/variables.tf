variable "prefix" {
  type        = string
  description = "Enterprise naming prefix."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "resource_group_name" {
  type        = string
  description = "Security resource group name."
}

variable "tenant_id" {
  type        = string
  description = "Azure AD tenant ID."
}

variable "current_object_id" {
  type        = string
  description = "Object ID of the current deployment principal."
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID used for Key Vault private endpoint."
}

variable "private_dns_zone_vnet_link_id" {
  type        = string
  description = "Hub VNet ID linked to the Key Vault private DNS zone."
}

variable "create_key_vault_private_endpoint" {
  type        = bool
  description = "Whether to create a Key Vault private endpoint."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags."
}
