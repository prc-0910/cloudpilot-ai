locals {
  prefix = lower(replace("${var.workload}-${var.environment}", "_", "-"))

  common_tags = merge(var.tags, {
    Environment = var.environment
    Workload    = var.workload
  })
}

data "azurerm_client_config" "current" {}

module "resource_groups" {
  source = "./modules/resource-group"

  prefix      = local.prefix
  location    = var.location
  dr_location = var.dr_location
  tags        = local.common_tags
}

module "network" {
  source = "./modules/network"

  prefix               = local.prefix
  location             = var.location
  resource_group_name  = module.resource_groups.network_resource_group_name
  hub_address_space    = var.hub_address_space
  hub_subnets          = var.hub_subnets
  spoke_address_spaces = var.spoke_address_spaces
  spoke_subnets        = var.spoke_subnets
  allowed_admin_cidrs  = var.allowed_admin_cidrs
  tags                 = local.common_tags
}

module "firewall" {
  source = "./modules/firewall"

  prefix                = local.prefix
  location              = var.location
  resource_group_name   = module.resource_groups.network_resource_group_name
  firewall_subnet_id    = module.network.hub_subnet_ids["AzureFirewallSubnet"]
  firewall_sku_tier     = var.firewall_sku_tier
  spoke_route_table_ids = module.network.spoke_route_table_ids
  tags                  = local.common_tags
}

module "monitoring" {
  source = "./modules/monitoring"

  prefix                     = local.prefix
  location                   = var.location
  resource_group_name        = module.resource_groups.management_resource_group_name
  log_retention_days         = var.log_retention_days
  diagnostic_target_ids      = concat([module.firewall.firewall_id, module.firewall.firewall_policy_id, module.network.ddos_protection_plan_id], module.network.vnet_ids)
  action_group_email_name    = "cloud-operations"
  action_group_email_address = "cloud-operations@example.com"
  tags                       = local.common_tags
}

module "backup" {
  source = "./modules/backup"

  prefix                     = local.prefix
  location                   = var.location
  resource_group_name        = module.resource_groups.recovery_resource_group_name
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  backup_time                = var.backup_time
  retention_daily_count      = var.backup_retention_daily_count
  retention_weekly_count     = var.backup_retention_weekly_count
  tags                       = local.common_tags
}

module "recovery" {
  source = "./modules/recovery"

  prefix                           = local.prefix
  location                         = var.location
  dr_location                      = var.dr_location
  resource_group_name              = module.resource_groups.recovery_resource_group_name
  source_recovery_vault_name       = module.backup.recovery_services_vault_name
  source_recovery_vault_id         = module.backup.recovery_services_vault_id
  source_vnet_id                   = module.network.spoke_vnet_ids["migration"]
  target_vnet_id                   = module.network.spoke_vnet_ids["dr"]
  target_resource_group_id         = module.resource_groups.dr_resource_group_id
  vmware_process_server_name       = var.asr_vmware_process_server_name
  vmware_master_target_server_name = var.asr_vmware_master_target_server_name
  log_analytics_workspace_id       = module.monitoring.log_analytics_workspace_id
  tags                             = local.common_tags
}

module "security" {
  source = "./modules/security"

  prefix                            = local.prefix
  location                          = var.location
  resource_group_name               = module.resource_groups.security_resource_group_name
  tenant_id                         = data.azurerm_client_config.current.tenant_id
  current_object_id                 = data.azurerm_client_config.current.object_id
  private_endpoint_subnet_id        = module.network.hub_subnet_ids["PrivateEndpointSubnet"]
  private_dns_zone_vnet_link_id     = module.network.hub_vnet_id
  create_key_vault_private_endpoint = var.create_key_vault_private_endpoint
  log_analytics_workspace_id        = module.monitoring.log_analytics_workspace_id
  tags                              = local.common_tags
}
