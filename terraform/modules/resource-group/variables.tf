variable "prefix" {
  description = "Enterprise naming prefix."
  type        = string
}

variable "location" {
  description = "Primary Azure region."
  type        = string
}

variable "dr_location" {
  description = "Secondary Azure region."
  type        = string
}

variable "tags" {
  description = "Tags applied to resource groups."
  type        = map(string)
}
