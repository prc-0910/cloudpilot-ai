resource "azurerm_resource_group" "network" {
  name     = "rg-${var.prefix}-network"
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "management" {
  name     = "rg-${var.prefix}-management"
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "security" {
  name     = "rg-${var.prefix}-security"
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "recovery" {
  name     = "rg-${var.prefix}-recovery"
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "dr" {
  name     = "rg-${var.prefix}-dr"
  location = var.dr_location
  tags     = var.tags
}
