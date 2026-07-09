resource "azurerm_public_ip" "firewall" {
  name                = "pip-${var.prefix}-afw"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = var.tags
}

resource "azurerm_firewall_policy" "this" {
  name                     = "afwp-${var.prefix}"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  sku                      = var.firewall_sku_tier
  threat_intelligence_mode = "Deny"
  tags                     = var.tags

  dns {
    proxy_enabled = true
  }

  intrusion_detection {
    mode = "Alert"
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "baseline" {
  name               = "default-baseline"
  firewall_policy_id = azurerm_firewall_policy.this.id
  priority           = 100

  network_rule_collection {
    name     = "allow-azure-platform"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "allow-azure-monitor"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.0.0/8"]
      destination_addresses = ["AzureMonitor"]
      destination_ports     = ["443"]
    }

    rule {
      name                  = "allow-storage"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.0.0/8"]
      destination_addresses = ["Storage"]
      destination_ports     = ["443"]
    }
  }

  application_rule_collection {
    name     = "allow-microsoft-control-plane"
    priority = 200
    action   = "Allow"

    rule {
      name = "allow-microsoft"

      protocols {
        type = "Https"
        port = 443
      }

      source_addresses  = ["10.0.0.0/8"]
      destination_fqdns = ["*.microsoft.com", "*.windows.net", "*.azure.com"]
    }
  }
}

resource "azurerm_firewall" "this" {
  name                = "afw-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = var.firewall_sku_tier
  firewall_policy_id  = azurerm_firewall_policy.this.id
  zones               = ["1", "2", "3"]
  tags                = var.tags

  ip_configuration {
    name                 = "ipconfig"
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

resource "azurerm_route" "default_to_firewall" {
  for_each = var.spoke_route_table_ids

  name                   = "default-to-azure-firewall"
  resource_group_name    = var.resource_group_name
  route_table_name       = split("/", each.value)[length(split("/", each.value)) - 1]
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.this.ip_configuration[0].private_ip_address
}
