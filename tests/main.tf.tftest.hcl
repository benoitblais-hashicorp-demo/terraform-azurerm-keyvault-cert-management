provider "azurerm" {
  features {}
}

run "apply_certificate_contacts_with_fixture" {
  command = apply

  module {
    source = "./tests/fixtures/basic"
  }

  variables {
    key_vault_name      = "kv${substr(replace(uuid(), "-", ""), 0, 20)}"
    location            = "eastus"
    resource_group_name = "rg-${substr(replace(uuid(), "-", ""), 0, 10)}"

    certificate_contacts = {
      contacts = [
        {
          email = "pki-ops@example.com"
          name  = "PKI Ops"
        }
      ]
    }
  }

  assert {
    condition     = output.key_vault_id != null && output.key_vault_id != ""
    error_message = "Fixture Key Vault ID must be created and exported."
  }

  assert {
    condition     = output.certificate_contacts_id != null && output.certificate_contacts_id != ""
    error_message = "Certificate contacts ID must be exported when contacts are configured."
  }

  assert {
    condition     = length(output.certificate_issuers_ids) == 0
    error_message = "No certificate issuers should be created when certificate_issuers is not provided."
  }

  assert {
    condition     = length(output.certificates_ids) == 0
    error_message = "No certificates should be created when certificates is not provided."
  }
}

run "plan_empty_optional_resources" {
  command = plan

  variables {
    key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.KeyVault/vaults/kv-test"
  }

  assert {
    condition     = length(azurerm_key_vault_certificate_contacts.this) == 0
    error_message = "Certificate contacts resource must not be created when certificate_contacts is null."
  }

  assert {
    condition     = length(azurerm_key_vault_certificate_issuer.this) == 0
    error_message = "Certificate issuer resources must not be created when certificate_issuers is empty."
  }

  assert {
    condition     = length(azurerm_key_vault_certificate.this) == 0
    error_message = "Certificate resources must not be created when certificates is empty."
  }
}