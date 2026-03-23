resource "azurerm_key_vault_certificate_contacts" "this" {
  for_each = var.certificate_contacts == null ? {} : { "default" = var.certificate_contacts }

  key_vault_id = var.key_vault_id

  dynamic "contact" {
    for_each = coalesce(try(each.value.contacts, null), [])

    content {
      email = contact.value.email
      name  = try(contact.value.name, null)
      phone = try(contact.value.phone, null)
    }
  }

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) != null ? [each.value.timeouts] : []

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azurerm_key_vault_certificate_issuer" "this" {
  for_each = {
    for issuer in var.certificate_issuers : issuer.name => issuer
  }

  key_vault_id  = var.key_vault_id
  name          = each.value.name
  provider_name = each.value.provider_name
  account_id    = try(each.value.account_id, null)
  org_id        = try(each.value.org_id, null)
  password      = try(each.value.password, null)

  dynamic "admin" {
    for_each = coalesce(try(each.value.admin, null), [])

    content {
      email_address = admin.value.email_address
      first_name    = try(admin.value.first_name, null)
      last_name     = try(admin.value.last_name, null)
      phone         = try(admin.value.phone, null)
    }
  }

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) != null ? [each.value.timeouts] : []

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azurerm_key_vault_certificate" "this" {
  for_each = {
    for certificate in var.certificates : certificate.name => certificate
  }

  key_vault_id = var.key_vault_id
  name         = each.value.name
  tags         = try(each.value.tags, null)

  dynamic "certificate" {
    for_each = try(each.value.certificate, null) != null ? [each.value.certificate] : []

    content {
      contents = certificate.value.contents
      password = try(certificate.value.password, null)
    }
  }

  dynamic "certificate_policy" {
    for_each = try(each.value.certificate_policy, null) != null ? [each.value.certificate_policy] : []

    content {
      issuer_parameters {
        name = certificate_policy.value.issuer_parameters.name
      }

      key_properties {
        curve      = try(certificate_policy.value.key_properties.curve, null)
        exportable = certificate_policy.value.key_properties.exportable
        key_size   = try(certificate_policy.value.key_properties.key_size, null)
        key_type   = certificate_policy.value.key_properties.key_type
        reuse_key  = certificate_policy.value.key_properties.reuse_key
      }

      dynamic "lifetime_action" {
        for_each = coalesce(try(certificate_policy.value.lifetime_action, null), [])

        content {
          action {
            action_type = lifetime_action.value.action.action_type
          }

          trigger {
            days_before_expiry  = try(lifetime_action.value.trigger.days_before_expiry, null)
            lifetime_percentage = try(lifetime_action.value.trigger.lifetime_percentage, null)
          }
        }
      }

      secret_properties {
        content_type = certificate_policy.value.secret_properties.content_type
      }

      dynamic "x509_certificate_properties" {
        for_each = try(certificate_policy.value.x509_certificate_properties, null) != null ? [certificate_policy.value.x509_certificate_properties] : []

        content {
          extended_key_usage = try(x509_certificate_properties.value.extended_key_usage, null)
          key_usage          = x509_certificate_properties.value.key_usage
          subject            = x509_certificate_properties.value.subject
          validity_in_months = x509_certificate_properties.value.validity_in_months

          dynamic "subject_alternative_names" {
            for_each = try(x509_certificate_properties.value.subject_alternative_names, null) != null ? [x509_certificate_properties.value.subject_alternative_names] : []

            content {
              dns_names = try(subject_alternative_names.value.dns_names, null)
              emails    = try(subject_alternative_names.value.emails, null)
              upns      = try(subject_alternative_names.value.upns, null)
            }
          }
        }
      }
    }
  }

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) != null ? [each.value.timeouts] : []

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}