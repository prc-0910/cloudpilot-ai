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
  description = "Recovery resource group name."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID."
}

variable "backup_time" {
  type        = string
  description = "Daily backup time in UTC."
}

variable "retention_daily_count" {
  type        = number
  description = "Daily recovery point retention count."
}

variable "retention_weekly_count" {
  type        = number
  description = "Weekly recovery point retention count."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags."
}
