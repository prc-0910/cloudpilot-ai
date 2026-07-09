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
  description = "Management resource group name."
}

variable "log_retention_days" {
  type        = number
  description = "Log Analytics retention period."
}

variable "diagnostic_target_ids" {
  type        = list(string)
  description = "Resource IDs that should send diagnostics to Log Analytics."
}

variable "action_group_email_name" {
  type        = string
  description = "Operations email receiver display name."
}

variable "action_group_email_address" {
  type        = string
  description = "Operations email receiver address."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags."
}
