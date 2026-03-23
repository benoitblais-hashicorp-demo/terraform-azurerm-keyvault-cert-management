output "certificate_contacts" {
  description = "The Key Vault Certificate Contacts resource if configured."
  value       = try(azurerm_key_vault_certificate_contacts.this["default"], null)
}

output "certificate_contacts_id" {
  description = "The ID of the Key Vault Certificate Contacts resource if configured."
  value       = try(azurerm_key_vault_certificate_contacts.this["default"].id, null)
}

output "certificate_issuers" {
  description = "Key Vault Certificate Issuer resources keyed by issuer name."
  value       = azurerm_key_vault_certificate_issuer.this
}

output "certificate_issuers_ids" {
  description = "The IDs of Key Vault Certificate Issuer resources keyed by issuer name."
  value = {
    for key, issuer in azurerm_key_vault_certificate_issuer.this : key => issuer.id
  }
}

output "certificates" {
  description = "Key Vault Certificate resources keyed by certificate name."
  value       = azurerm_key_vault_certificate.this
}

output "certificates_ids" {
  description = "The IDs of Key Vault Certificate resources keyed by certificate name."
  value = {
    for key, certificate in azurerm_key_vault_certificate.this : key => certificate.id
  }
}

output "certificates_resource_manager_ids" {
  description = "The versioned Resource Manager IDs of Key Vault Certificates keyed by certificate name."
  value = {
    for key, certificate in azurerm_key_vault_certificate.this : key => certificate.resource_manager_id
  }
}

output "certificates_resource_manager_versionless_ids" {
  description = "The versionless Resource Manager IDs of Key Vault Certificates keyed by certificate name."
  value = {
    for key, certificate in azurerm_key_vault_certificate.this : key => certificate.resource_manager_versionless_id
  }
}

output "certificates_secret_ids" {
  description = "The secret IDs associated with Key Vault Certificates keyed by certificate name."
  value = {
    for key, certificate in azurerm_key_vault_certificate.this : key => certificate.secret_id
  }
}

output "certificates_versions" {
  description = "The current versions of Key Vault Certificates keyed by certificate name."
  value = {
    for key, certificate in azurerm_key_vault_certificate.this : key => certificate.version
  }
}