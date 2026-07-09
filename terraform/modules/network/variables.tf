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

variable "hub_address_space" {
  type        = list(string)
  description = "Hub VNet address space."
}

variable "hub_subnets" {
  type = map(object({
    address_prefixes                              = list(string)
    private_endpoint_network_policies_enabled     = optional(bool, true)
    private_link_service_network_policies_enabled = optional(bool, true)
  }))
  description = "Hub subnet map."
}

variable "spoke_address_spaces" {
  type        = map(list(string))
  description = "Spoke VNet address spaces."
}

variable "spoke_subnets" {
  type = map(map(object({
    address_prefixes                          = list(string)
    private_endpoint_network_policies_enabled = optional(bool, true)
    service_endpoints                         = optional(list(string), [])
  })))
  description = "Spoke subnet map."
}

variable "allowed_admin_cidrs" {
  type        = list(string)
  description = "Reserved for NSG hardening where direct admin CIDRs are used."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags."
}
