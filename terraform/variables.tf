variable "environment" {
  description = "Environment code used in enterprise naming, for example prod, nonprod, dr."
  type        = string
  default     = "prod"

  validation {
    condition     = can(regex("^[a-z0-9-]{2,12}$", var.environment))
    error_message = "Environment must be 2-12 lowercase letters, numbers, or hyphens."
  }
}

variable "workload" {
  description = "Workload or application portfolio name."
  type        = string
  default     = "vmware-migration"
}

variable "location" {
  description = "Primary Azure region."
  type        = string
  default     = "eastus"
}

variable "dr_location" {
  description = "Secondary Azure region used for disaster recovery."
  type        = string
  default     = "westus2"
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default = {
    CostCenter  = "shared"
    Owner       = "cloud-platform"
    ManagedBy   = "terraform"
    Criticality = "mission-critical"
  }
}

variable "hub_address_space" {
  description = "Address space for the hub virtual network."
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "spoke_address_spaces" {
  description = "Map of spoke names to address spaces."
  type        = map(list(string))
  default = {
    migration = ["10.20.0.0/16"]
    dr        = ["10.30.0.0/16"]
  }
}

variable "hub_subnets" {
  description = "Hub subnet definitions. AzureFirewallSubnet and AzureBastionSubnet names are required by Azure."
  type = map(object({
    address_prefixes                              = list(string)
    private_endpoint_network_policies_enabled     = optional(bool, true)
    private_link_service_network_policies_enabled = optional(bool, true)
  }))
  default = {
    AzureFirewallSubnet = {
      address_prefixes = ["10.10.0.0/26"]
    }
    AzureBastionSubnet = {
      address_prefixes = ["10.10.0.64/26"]
    }
    PrivateEndpointSubnet = {
      address_prefixes                          = ["10.10.1.0/24"]
      private_endpoint_network_policies_enabled = false
    }
    GatewaySubnet = {
      address_prefixes = ["10.10.2.0/27"]
    }
  }
}

variable "spoke_subnets" {
  description = "Subnet definitions for each spoke."
  type = map(map(object({
    address_prefixes                          = list(string)
    private_endpoint_network_policies_enabled = optional(bool, true)
    service_endpoints                         = optional(list(string), [])
  })))
  default = {
    migration = {
      workloads = {
        address_prefixes  = ["10.20.1.0/24"]
        service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      }
      private-endpoints = {
        address_prefixes                          = ["10.20.2.0/24"]
        private_endpoint_network_policies_enabled = false
      }
    }
    dr = {
      workloads = {
        address_prefixes  = ["10.30.1.0/24"]
        service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      }
      private-endpoints = {
        address_prefixes                          = ["10.30.2.0/24"]
        private_endpoint_network_policies_enabled = false
      }
    }
  }
}

variable "allowed_admin_cidrs" {
  description = "CIDR ranges allowed to reach Bastion and administrative endpoints."
  type        = list(string)
  default     = []
}

variable "firewall_sku_tier" {
  description = "Azure Firewall tier. Premium is required by the architecture."
  type        = string
  default     = "Premium"

  validation {
    condition     = contains(["Premium"], var.firewall_sku_tier)
    error_message = "This project is designed for Azure Firewall Premium."
  }
}

variable "log_retention_days" {
  description = "Log Analytics retention period in days."
  type        = number
  default     = 365
}

variable "backup_retention_daily_count" {
  description = "Number of daily Azure VM backup recovery points to retain."
  type        = number
  default     = 30
}

variable "backup_retention_weekly_count" {
  description = "Number of weekly Azure VM backup recovery points to retain."
  type        = number
  default     = 52
}

variable "backup_time" {
  description = "UTC time for daily VM backup, formatted as HH:MM."
  type        = string
  default     = "23:00"
}

variable "asr_vmware_process_server_name" {
  description = "Name of the VMware ASR process server after registration."
  type        = string
  default     = "asr-process-server-01"
}

variable "asr_vmware_master_target_server_name" {
  description = "Name of the VMware ASR master target server after registration."
  type        = string
  default     = "asr-master-target-01"
}

variable "create_key_vault_private_endpoint" {
  description = "Create a Key Vault private endpoint in the hub private endpoint subnet."
  type        = bool
  default     = true
}
