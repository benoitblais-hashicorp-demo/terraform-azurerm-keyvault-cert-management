provider "azurerm" {
  features {}
}

data "azurerm_client_config" "this" {}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_key_vault" "this" {
  name                       = var.key_vault_name
  location                   = azurerm_resource_group.this.location
  resource_group_name        = azurerm_resource_group.this.name
  tenant_id                  = data.azurerm_client_config.this.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
}

resource "azurerm_key_vault_access_policy" "this" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = data.azurerm_client_config.this.tenant_id
  object_id    = data.azurerm_client_config.this.object_id

  certificate_permissions = [
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "SetIssuers",
    "Update",
  ]

  key_permissions = [
    "Create",
    "Get",
    "Import",
    "List",
    "Update",
  ]

  secret_permissions = [
    "Get",
    "List",
    "Set",
  ]
}

module "this" {
  source = "../../.."

  key_vault_id = azurerm_key_vault.this.id

  certificate_contacts = var.certificate_contacts
  certificate_issuers  = var.certificate_issuers
  certificates         = var.certificates

  depends_on = [
    azurerm_key_vault_access_policy.this,
  ]
}
