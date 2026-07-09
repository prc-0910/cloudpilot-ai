output "ddos_protection_plan_id" {
  value = azurerm_network_ddos_protection_plan.this.id
}

output "hub_vnet_id" {
  value = azurerm_virtual_network.hub.id
}

output "hub_subnet_ids" {
  value = { for name, subnet in azurerm_subnet.hub : name => subnet.id }
}

output "spoke_vnet_ids" {
  value = { for name, vnet in azurerm_virtual_network.spoke : name => vnet.id }
}

output "spoke_subnet_ids" {
  value = { for name, subnet in azurerm_subnet.spoke : name => subnet.id }
}

output "spoke_route_table_ids" {
  value = { for name, route_table in azurerm_route_table.spoke : name => route_table.id }
}

output "vnet_ids" {
  value = concat([azurerm_virtual_network.hub.id], [for vnet in azurerm_virtual_network.spoke : vnet.id])
}

output "bastion_fqdn" {
  value = azurerm_bastion_host.this.dns_name
}
