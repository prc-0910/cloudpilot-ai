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
  description = "Network resource group name."
}

variable "firewall_subnet_id" {
  type        = string
  description = "AzureFirewallSubnet resource ID."
}

variable "firewall_sku_tier" {
  type        = string
  description = "Azure Firewall SKU tier."
}

variable "spoke_route_table_ids" {
  type        = map(string)
  description = "Spoke route table IDs that should default route through Azure Firewall."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags."
}
