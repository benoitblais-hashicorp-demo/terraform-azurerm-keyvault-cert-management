variable "key_vault_name" {
  description = "(Required) Name of the Key Vault created by the test fixture."
  type        = string
}

variable "location" {
  description = "(Required) Azure location used by the test fixture resources."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) Name of the resource group created by the test fixture."
  type        = string
}

variable "certificate_contacts" {
  description = "(Optional) Certificate contacts configuration passed through to the module under test."
  type = object({
    contacts = optional(list(object({
      email = string
      name  = optional(string)
      phone = optional(string)
    })), [])
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })
  default = null
}

variable "certificate_issuers" {
  description = "(Optional) Certificate issuer definitions passed through to the module under test."
  type = list(object({
    name          = string
    provider_name = string
    account_id    = optional(string)
    admin = optional(list(object({
      email_address = string
      first_name    = optional(string)
      last_name     = optional(string)
      phone         = optional(string)
    })), [])
    org_id   = optional(string)
    password = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = []
}

variable "certificates" {
  description = "(Optional) Certificate definitions passed through to the module under test."
  type = list(object({
    name = string
    certificate = optional(object({
      contents = string
      password = optional(string)
    }))
    certificate_policy = optional(object({
      issuer_parameters = object({
        name = string
      })
      key_properties = object({
        curve      = optional(string)
        exportable = bool
        key_size   = optional(number)
        key_type   = string
        reuse_key  = bool
      })
      lifetime_action = optional(list(object({
        action = object({
          action_type = string
        })
        trigger = object({
          days_before_expiry  = optional(number)
          lifetime_percentage = optional(number)
        })
      })), [])
      secret_properties = object({
        content_type = string
      })
      x509_certificate_properties = optional(object({
        extended_key_usage = optional(list(string))
        key_usage          = list(string)
        subject            = string
        subject_alternative_names = optional(object({
          dns_names = optional(list(string))
          emails    = optional(list(string))
          upns      = optional(list(string))
        }))
        validity_in_months = number
      }))
    }))
    tags = optional(map(string))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default = []
}
