provider "azurerm" {
  features {}
}

run "valid_minimal_input" {
  command = plan

  variables {
    key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.KeyVault/vaults/kv-test"
  }
}

run "invalid_certificate_contacts_email" {
  command = plan

  variables {
    key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.KeyVault/vaults/kv-test"

    certificate_contacts = {
      contacts = [
        {
          email = "invalid-email"
        }
      ]
    }
  }

  expect_failures = [
    var.certificate_contacts,
  ]
}

run "invalid_certificate_issuers_provider_name" {
  command = plan

  variables {
    key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.KeyVault/vaults/kv-test"

    certificate_issuers = [
      {
        name          = "issuer-1"
        provider_name = "InvalidIssuer"
      }
    ]
  }

  expect_failures = [
    var.certificate_issuers,
  ]
}

run "invalid_certificate_issuers_duplicate_name" {
  command = plan

  variables {
    key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.KeyVault/vaults/kv-test"

    certificate_issuers = [
      {
        name          = "issuer-dup"
        provider_name = "DigiCert"
      },
      {
        name          = "issuer-dup"
        provider_name = "GlobalSign"
      }
    ]
  }

  expect_failures = [
    var.certificate_issuers,
  ]
}

run "invalid_certificate_issuers_admin_email" {
  command = plan

  variables {
    key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.KeyVault/vaults/kv-test"

    certificate_issuers = [
      {
        name          = "issuer-admin"
        provider_name = "DigiCert"
        admin = [
          {
            email_address = "not-an-email"
          }
        ]
      }
    ]
  }

  expect_failures = [
    var.certificate_issuers,
  ]
}

run "invalid_certificates_missing_certificate_and_policy" {
  command = plan

  variables {
    key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.KeyVault/vaults/kv-test"

    certificates = [
      {
        name = "cert-1"
      }
    ]
  }

  expect_failures = [
    var.certificates,
  ]
}

run "invalid_certificates_missing_x509_without_import" {
  command = plan

  variables {
    key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.KeyVault/vaults/kv-test"

    certificates = [
      {
        name = "cert-2"
        certificate_policy = {
          issuer_parameters = {
            name = "Self"
          }
          key_properties = {
            exportable = true
            key_size   = 2048
            key_type   = "RSA"
            reuse_key  = true
          }
          secret_properties = {
            content_type = "application/x-pkcs12"
          }
        }
      }
    ]
  }

  expect_failures = [
    var.certificates,
  ]
}

run "invalid_certificates_duplicate_name" {
  command = plan

  variables {
    key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.KeyVault/vaults/kv-test"

    certificates = [
      {
        name = "cert-dup"
        certificate = {
          contents = "dGVzdA=="
        }
      },
      {
        name = "cert-dup"
        certificate = {
          contents = "dGVzdDI="
        }
      }
    ]
  }

  expect_failures = [
    var.certificates,
  ]
}

run "invalid_certificates_key_type" {
  command = plan

  variables {
    key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.KeyVault/vaults/kv-test"

    certificates = [
      {
        name = "cert-3"
        certificate_policy = {
          issuer_parameters = {
            name = "Self"
          }
          key_properties = {
            exportable = true
            key_size   = 2048
            key_type   = "INVALID"
            reuse_key  = true
          }
          secret_properties = {
            content_type = "application/x-pkcs12"
          }
          x509_certificate_properties = {
            key_usage          = ["digitalSignature"]
            subject            = "CN=example.com"
            validity_in_months = 12
          }
        }
      }
    ]
  }

  expect_failures = [
    var.certificates,
  ]
}

run "invalid_certificates_curve" {
  command = plan

  variables {
    key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.KeyVault/vaults/kv-test"

    certificates = [
      {
        name = "cert-4"
        certificate_policy = {
          issuer_parameters = {
            name = "Self"
          }
          key_properties = {
            curve      = "P-999"
            exportable = true
            key_type   = "EC"
            reuse_key  = true
          }
          secret_properties = {
            content_type = "application/x-pkcs12"
          }
          x509_certificate_properties = {
            key_usage          = ["digitalSignature"]
            subject            = "CN=example.com"
            validity_in_months = 12
          }
        }
      }
    ]
  }

  expect_failures = [
    var.certificates,
  ]
}

run "invalid_certificates_rsa_missing_key_size" {
  command = plan

  variables {
    key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.KeyVault/vaults/kv-test"

    certificates = [
      {
        name = "cert-5"
        certificate_policy = {
          issuer_parameters = {
            name = "Self"
          }
          key_properties = {
            exportable = true
            key_type   = "RSA"
            reuse_key  = true
          }
          secret_properties = {
            content_type = "application/x-pkcs12"
          }
          x509_certificate_properties = {
            key_usage          = ["digitalSignature"]
            subject            = "CN=example.com"
            validity_in_months = 12
          }
        }
      }
    ]
  }

  expect_failures = [
    var.certificates,
  ]
}

run "invalid_certificates_lifetime_trigger_conflict" {
  command = plan

  variables {
    key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.KeyVault/vaults/kv-test"

    certificates = [
      {
        name = "cert-6"
        certificate_policy = {
          issuer_parameters = {
            name = "Self"
          }
          key_properties = {
            exportable = true
            key_size   = 2048
            key_type   = "RSA"
            reuse_key  = true
          }
          lifetime_action = [
            {
              action = {
                action_type = "AutoRenew"
              }
              trigger = {
                days_before_expiry  = 30
                lifetime_percentage = 80
              }
            }
          ]
          secret_properties = {
            content_type = "application/x-pkcs12"
          }
          x509_certificate_properties = {
            key_usage          = ["digitalSignature"]
            subject            = "CN=example.com"
            validity_in_months = 12
          }
        }
      }
    ]
  }

  expect_failures = [
    var.certificates,
  ]
}

run "invalid_certificates_lifetime_percentage_range" {
  command = plan

  variables {
    key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.KeyVault/vaults/kv-test"

    certificates = [
      {
        name = "cert-7"
        certificate_policy = {
          issuer_parameters = {
            name = "Self"
          }
          key_properties = {
            exportable = true
            key_size   = 2048
            key_type   = "RSA"
            reuse_key  = true
          }
          lifetime_action = [
            {
              action = {
                action_type = "AutoRenew"
              }
              trigger = {
                lifetime_percentage = 101
              }
            }
          ]
          secret_properties = {
            content_type = "application/x-pkcs12"
          }
          x509_certificate_properties = {
            key_usage          = ["digitalSignature"]
            subject            = "CN=example.com"
            validity_in_months = 12
          }
        }
      }
    ]
  }

  expect_failures = [
    var.certificates,
  ]
}

run "invalid_certificates_key_usage" {
  command = plan

  variables {
    key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.KeyVault/vaults/kv-test"

    certificates = [
      {
        name = "cert-8"
        certificate_policy = {
          issuer_parameters = {
            name = "Self"
          }
          key_properties = {
            exportable = true
            key_size   = 2048
            key_type   = "RSA"
            reuse_key  = true
          }
          secret_properties = {
            content_type = "application/x-pkcs12"
          }
          x509_certificate_properties = {
            key_usage          = ["invalidUsage"]
            subject            = "CN=example.com"
            validity_in_months = 12
          }
        }
      }
    ]
  }

  expect_failures = [
    var.certificates,
  ]
}

run "invalid_certificates_subject_alternative_email" {
  command = plan

  variables {
    key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.KeyVault/vaults/kv-test"

    certificates = [
      {
        name = "cert-9"
        certificate_policy = {
          issuer_parameters = {
            name = "Self"
          }
          key_properties = {
            exportable = true
            key_size   = 2048
            key_type   = "RSA"
            reuse_key  = true
          }
          secret_properties = {
            content_type = "application/x-pkcs12"
          }
          x509_certificate_properties = {
            key_usage          = ["digitalSignature"]
            subject            = "CN=example.com"
            validity_in_months = 12
            subject_alternative_names = {
              emails = ["invalid-email"]
            }
          }
        }
      }
    ]
  }

  expect_failures = [
    var.certificates,
  ]
}