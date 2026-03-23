output "certificate_contacts" {
  description = "Certificate contacts output from the module under test."
  value       = module.this.certificate_contacts
}

output "certificate_contacts_id" {
  description = "Certificate contacts ID output from the module under test."
  value       = module.this.certificate_contacts_id
}

output "certificate_issuers" {
  description = "Certificate issuers output from the module under test."
  value       = module.this.certificate_issuers
}

output "certificate_issuers_ids" {
  description = "Certificate issuer IDs output from the module under test."
  value       = module.this.certificate_issuers_ids
}

output "certificates" {
  description = "Certificates output from the module under test."
  value       = module.this.certificates
}

output "certificates_ids" {
  description = "Certificate IDs output from the module under test."
  value       = module.this.certificates_ids
}

output "certificates_resource_manager_ids" {
  description = "Versioned Resource Manager IDs for certificates from the module under test."
  value       = module.this.certificates_resource_manager_ids
}

output "certificates_resource_manager_versionless_ids" {
  description = "Versionless Resource Manager IDs for certificates from the module under test."
  value       = module.this.certificates_resource_manager_versionless_ids
}

output "certificates_secret_ids" {
  description = "Secret IDs associated with certificates from the module under test."
  value       = module.this.certificates_secret_ids
}

output "certificates_versions" {
  description = "Certificate versions output from the module under test."
  value       = module.this.certificates_versions
}

output "key_vault_id" {
  description = "ID of the Key Vault created by the test fixture."
  value       = azurerm_key_vault.this.id
}

output "resource_group_name" {
  description = "Name of the resource group created by the test fixture."
  value       = azurerm_resource_group.this.name
}
