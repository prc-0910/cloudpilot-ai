resource "azurerm_network_ddos_protection_plan" "this" {
  name                = "ddos-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-${var.prefix}-hub"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.hub_address_space
  tags                = var.tags

  ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.this.id
    enable = true
  }
}

resource "azurerm_subnet" "hub" {
  for_each = var.hub_subnets

  name                                          = each.key
  resource_group_name                           = var.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.hub.name
  address_prefixes                              = each.value.address_prefixes
  private_endpoint_network_policies             = each.value.private_endpoint_network_policies_enabled ? "Enabled" : "Disabled"
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled
}

resource "azurerm_public_ip" "bastion" {
  name                = "pip-${var.prefix}-bastion"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = var.tags
}

resource "azurerm_bastion_host" "this" {
  name                = "bas-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  copy_paste_enabled  = true
  file_copy_enabled   = true
  tunneling_enabled   = true
  tags                = var.tags

  ip_configuration {
    name                 = "ipconfig"
    subnet_id            = azurerm_subnet.hub["AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}

resource "azurerm_virtual_network" "spoke" {
  for_each = var.spoke_address_spaces

  name                = "vnet-${var.prefix}-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = each.value
  tags                = var.tags

  ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.this.id
    enable = true
  }
}

locals {
  spoke_subnets_flat = merge([
    for spoke_name, subnets in var.spoke_subnets : {
      for subnet_name, subnet in subnets : "${spoke_name}-${subnet_name}" => {
        spoke_name                                = spoke_name
        subnet_name                               = subnet_name
        address_prefixes                          = subnet.address_prefixes
        private_endpoint_network_policies_enabled = subnet.private_endpoint_network_policies_enabled
        service_endpoints                         = subnet.service_endpoints
      }
    }
  ]...)
}

resource "azurerm_subnet" "spoke" {
  for_each = local.spoke_subnets_flat

  name                              = "snet-${each.value.subnet_name}"
  resource_group_name               = var.resource_group_name
  virtual_network_name              = azurerm_virtual_network.spoke[each.value.spoke_name].name
  address_prefixes                  = each.value.address_prefixes
  private_endpoint_network_policies = each.value.private_endpoint_network_policies_enabled ? "Enabled" : "Disabled"
  service_endpoints                 = each.value.service_endpoints
}

resource "azurerm_network_security_group" "workloads" {
  for_each = var.spoke_address_spaces

  name                = "nsg-${var.prefix}-${each.key}-workloads"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "AllowVirtualNetworkInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "DenyInternetInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "workloads" {
  for_each = {
    for key, subnet in local.spoke_subnets_flat : key => subnet
    if subnet.subnet_name == "workloads"
  }

  subnet_id                 = azurerm_subnet.spoke[each.key].id
  network_security_group_id = azurerm_network_security_group.workloads[each.value.spoke_name].id
}

resource "azurerm_route_table" "spoke" {
  for_each = var.spoke_address_spaces

  name                          = "rt-${var.prefix}-${each.key}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  bgp_route_propagation_enabled = false
  tags                          = var.tags
}

resource "azurerm_subnet_route_table_association" "workloads" {
  for_each = {
    for key, subnet in local.spoke_subnets_flat : key => subnet
    if subnet.subnet_name == "workloads"
  }

  subnet_id      = azurerm_subnet.spoke[each.key].id
  route_table_id = azurerm_route_table.spoke[each.value.spoke_name].id
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  for_each = azurerm_virtual_network.spoke

  name                         = "peer-hub-to-${each.key}"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = each.value.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  for_each = azurerm_virtual_network.spoke

  name                         = "peer-${each.key}-to-hub"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = each.value.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = false
}
