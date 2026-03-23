output "certificate_contacts" {
  value = module.this.certificate_contacts
}

output "certificate_contacts_id" {
  value = module.this.certificate_contacts_id
}

output "certificate_issuers" {
  value = module.this.certificate_issuers
}

output "certificate_issuers_ids" {
  value = module.this.certificate_issuers_ids
}

output "certificates" {
  value = module.this.certificates
}

output "certificates_ids" {
  value = module.this.certificates_ids
}

output "certificates_resource_manager_ids" {
  value = module.this.certificates_resource_manager_ids
}

output "certificates_resource_manager_versionless_ids" {
  value = module.this.certificates_resource_manager_versionless_ids
}

output "certificates_secret_ids" {
  value = module.this.certificates_secret_ids
}

output "certificates_versions" {
  value = module.this.certificates_versions
}

output "key_vault_id" {
  value = azurerm_key_vault.this.id
}

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}
