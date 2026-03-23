variable "key_vault_id" {
  description = "(Required) The ID of the Key Vault where certificate management resources should be created. Changing this forces a new resource to be created for applicable resources."
  type        = string
}

variable "certificate_contacts" {
  description = <<DESCRIPTION
	(Optional) Configuration for Key Vault Certificate Contacts.
		contacts : (Optional) One or more `contact` blocks as defined below.
			email : (Required) E-mail address of the contact.
			name : (Optional) Name of the contact.
			phone : (Optional) Phone number of the contact.
		timeouts : (Optional) A `timeouts` block to configure operation timeouts for create, read, update, and delete actions.
			create : (Optional) Used when creating the Key Vault Certificate Contacts.
			read : (Optional) Used when retrieving the Key Vault Certificate Contacts.
			update : (Optional) Used when updating the Key Vault Certificate Contacts.
			delete : (Optional) Used when deleting the Key Vault Certificate Contacts.
	DESCRIPTION
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

  validation {
    condition = var.certificate_contacts == null ? true : alltrue([
      for contact in coalesce(try(var.certificate_contacts.contacts, null), []) :
      can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", contact.email))
    ])
    error_message = "`certificate_contacts.contacts[*].email` must be a valid email address."
  }
}

variable "certificate_issuers" {
  description = <<DESCRIPTION
	(Optional) A list of Key Vault Certificate Issuers.
		key_vault_id : (Required) The ID of the Key Vault in which to create the Certificate Issuer.
		name : (Required) The name which should be used for this Key Vault Certificate Issuer.
		provider_name : (Required) The name of the third-party Certificate Issuer.
		account_id : (Optional) The account number with the third-party Certificate Issuer.
		admin : (Optional) One or more `admin` blocks as defined below.
			email_address : (Required) E-mail address of the admin.
			first_name : (Optional) First name of the admin.
			last_name : (Optional) Last name of the admin.
			phone : (Optional) Phone number of the admin.
		org_id : (Optional) The ID of the organization as provided to the issuer.
		password : (Optional) The password associated with the account and organization ID at the third-party Certificate Issuer.
		timeouts : (Optional) A `timeouts` block to configure operation timeouts for create, read, update, and delete actions.
			create : (Optional) Used when creating the Key Vault Certificate Issuer.
			read : (Optional) Used when retrieving the Key Vault Certificate Issuer.
			update : (Optional) Used when updating the Key Vault Certificate Issuer.
			delete : (Optional) Used when deleting the Key Vault Certificate Issuer.
	DESCRIPTION
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

  validation {
    condition = alltrue([
      for issuer in var.certificate_issuers :
      contains(["DigiCert", "GlobalSign", "OneCertV2-PrivateCA", "OneCertV2-PublicCA", "SslAdminV2"], issuer.provider_name)
    ])
    error_message = "`certificate_issuers[*].provider_name` must be one of: \"DigiCert\", \"GlobalSign\", \"OneCertV2-PrivateCA\", \"OneCertV2-PublicCA\", \"SslAdminV2\"."
  }

  validation {
    condition = length(distinct([
      for issuer in var.certificate_issuers : issuer.name
    ])) == length(var.certificate_issuers)
    error_message = "`certificate_issuers[*].name` values must be unique."
  }

  validation {
    condition = alltrue(flatten([
      for issuer in var.certificate_issuers : [
        for admin in coalesce(try(issuer.admin, null), []) :
        can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", admin.email_address))
      ]
    ]))
    error_message = "`certificate_issuers[*].admin[*].email_address` must be a valid email address."
  }
}

variable "certificates" {
  description = <<DESCRIPTION
	(Optional) A list of Key Vault Certificates.
		key_vault_id : (Required) The ID of the Key Vault where the Certificate should be created.
		name : (Required) Specifies the name of the Key Vault Certificate.
		certificate : (Optional) A `certificate` block, used to import an existing certificate.
			contents : (Required) The base64-encoded certificate contents.
			password : (Optional) The password associated with the certificate.
		certificate_policy : (Optional) A `certificate_policy` block.
			issuer_parameters : (Required) A `issuer_parameters` block.
				name : (Required) The name of the Certificate Issuer.
			key_properties : (Required) A `key_properties` block.
				curve : (Optional) Specifies the curve to use when creating an `EC` key. Possible values are `P-256`, `P-256K`, `P-384`, and `P-521`.
				exportable : (Required) Is this certificate exportable?
				key_size : (Optional) The size of the key used in the certificate.
				key_type : (Required) Specifies the type of key. Possible values are `EC`, `EC-HSM`, `RSA`, `RSA-HSM` and `oct`.
				reuse_key : (Required) Is the key reusable?
			lifetime_action : (Optional) A `lifetime_action` block.
				action : (Required) A `action` block.
					action_type : (Required) The Type of action to be performed when the lifetime trigger is triggered. Possible values include `AutoRenew` and `EmailContacts`.
				trigger : (Required) A `trigger` block.
					days_before_expiry : (Optional) The number of days before the Certificate expires that the action associated with this Trigger should run.
					lifetime_percentage : (Optional) The percentage at which during the Certificates Lifetime the action associated with this Trigger should run.
			secret_properties : (Required) A `secret_properties` block.
				content_type : (Required) The Content-Type of the Certificate, such as `application/x-pkcs12` for a PFX or `application/x-pem-file` for a PEM.
			x509_certificate_properties : (Optional) A `x509_certificate_properties` block. Required when `certificate` block is not specified.
				extended_key_usage : (Optional) A list of Extended/Enhanced Key Usages.
				key_usage : (Required) A list of uses associated with this Key.
				subject : (Required) The Certificate's Subject.
				subject_alternative_names : (Optional) A `subject_alternative_names` block.
					dns_names : (Optional) A list of alternative DNS names (FQDNs) identified by the Certificate.
					emails : (Optional) A list of email addresses identified by this Certificate.
					upns : (Optional) A list of User Principal Names identified by the Certificate.
				validity_in_months : (Required) The Certificates Validity Period in Months.
		tags : (Optional) A mapping of tags to assign to the resource.
		timeouts : (Optional) A `timeouts` block to configure operation timeouts for create, read, update, and delete actions.
			create : (Optional) Used when creating the Key Vault Certificate.
			read : (Optional) Used when retrieving the Key Vault Certificate.
			update : (Optional) Used when updating the Key Vault Certificate.
			delete : (Optional) Used when deleting the Key Vault Certificate.
	DESCRIPTION
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

  validation {
    condition = alltrue([
      for certificate in var.certificates :
      try(certificate.certificate, null) != null || try(certificate.certificate_policy, null) != null
    ])
    error_message = "Each element in `certificates` must include at least one of `certificate` or `certificate_policy`."
  }

  validation {
    condition = alltrue([
      for certificate in var.certificates :
      try(certificate.certificate, null) != null ? true : try(certificate.certificate_policy.x509_certificate_properties, null) != null
    ])
    error_message = "`certificates[*].certificate_policy.x509_certificate_properties` is required when `certificates[*].certificate` is not specified."
  }

  validation {
    condition = length(distinct([
      for certificate in var.certificates : certificate.name
    ])) == length(var.certificates)
    error_message = "`certificates[*].name` values must be unique."
  }

  validation {
    condition = alltrue([
      for certificate in var.certificates :
      try(certificate.certificate_policy, null) == null ? true : contains(["EC", "EC-HSM", "RSA", "RSA-HSM", "oct"], certificate.certificate_policy.key_properties.key_type)
    ])
    error_message = "`certificates[*].certificate_policy.key_properties.key_type` must be one of: \"EC\", \"EC-HSM\", \"RSA\", \"RSA-HSM\", \"oct\"."
  }

  validation {
    condition = alltrue([
      for certificate in var.certificates :
      try(certificate.certificate_policy, null) == null || try(certificate.certificate_policy.key_properties.curve, null) == null ? true : contains(["P-256", "P-256K", "P-384", "P-521"], certificate.certificate_policy.key_properties.curve)
    ])
    error_message = "`certificates[*].certificate_policy.key_properties.curve` must be one of: \"P-256\", \"P-256K\", \"P-384\", \"P-521\"."
  }

  validation {
    condition = alltrue([
      for certificate in var.certificates :
      try(certificate.certificate_policy, null) == null ? true : (
        contains(["RSA", "RSA-HSM"], certificate.certificate_policy.key_properties.key_type) ? try(certificate.certificate_policy.key_properties.key_size, null) != null : true
      )
    ])
    error_message = "`certificates[*].certificate_policy.key_properties.key_size` is required when `key_type` is \"RSA\" or \"RSA-HSM\"."
  }

  validation {
    condition = alltrue([
      for certificate in var.certificates :
      try(certificate.certificate_policy, null) == null || try(certificate.certificate_policy.key_properties.key_size, null) == null ? true : contains([2048, 3072, 4096, 256, 384, 521], certificate.certificate_policy.key_properties.key_size)
    ])
    error_message = "`certificates[*].certificate_policy.key_properties.key_size` must be one of: 2048, 3072, 4096, 256, 384, 521."
  }

  validation {
    condition = alltrue(flatten([
      for certificate in var.certificates : [
        for action in coalesce(try(certificate.certificate_policy.lifetime_action, null), []) :
        contains(["AutoRenew", "EmailContacts"], action.action.action_type)
      ]
    ]))
    error_message = "`certificates[*].certificate_policy.lifetime_action[*].action.action_type` must be one of: \"AutoRenew\", \"EmailContacts\"."
  }

  validation {
    condition = alltrue(flatten([
      for certificate in var.certificates : [
        for action in coalesce(try(certificate.certificate_policy.lifetime_action, null), []) :
        (
          (try(action.trigger.days_before_expiry, null) == null) != (try(action.trigger.lifetime_percentage, null) == null)
        )
      ]
    ]))
    error_message = "Each `trigger` must set exactly one of `days_before_expiry` or `lifetime_percentage`."
  }

  validation {
    condition = alltrue(flatten([
      for certificate in var.certificates : [
        for action in coalesce(try(certificate.certificate_policy.lifetime_action, null), []) :
        try(action.trigger.days_before_expiry, null) == null ? true : action.trigger.days_before_expiry > 0
      ]
    ]))
    error_message = "`certificates[*].certificate_policy.lifetime_action[*].trigger.days_before_expiry` must be greater than 0 when specified."
  }

  validation {
    condition = alltrue(flatten([
      for certificate in var.certificates : [
        for action in coalesce(try(certificate.certificate_policy.lifetime_action, null), []) :
        try(action.trigger.lifetime_percentage, null) == null ? true : (action.trigger.lifetime_percentage > 0 && action.trigger.lifetime_percentage <= 100)
      ]
    ]))
    error_message = "`certificates[*].certificate_policy.lifetime_action[*].trigger.lifetime_percentage` must be between 1 and 100 when specified."
  }

  validation {
    condition = alltrue([
      for certificate in var.certificates :
      try(certificate.certificate_policy.x509_certificate_properties, null) == null ? true : alltrue([
        for key_usage in certificate.certificate_policy.x509_certificate_properties.key_usage :
        contains(["cRLSign", "dataEncipherment", "decipherOnly", "digitalSignature", "encipherOnly", "keyAgreement", "keyCertSign", "keyEncipherment", "nonRepudiation"], key_usage)
      ])
    ])
    error_message = "`certificates[*].certificate_policy.x509_certificate_properties.key_usage` entries must be valid Key Usage values."
  }

  validation {
    condition = alltrue([
      for certificate in var.certificates :
      try(certificate.certificate_policy.x509_certificate_properties, null) == null ? true : certificate.certificate_policy.x509_certificate_properties.validity_in_months > 0
    ])
    error_message = "`certificates[*].certificate_policy.x509_certificate_properties.validity_in_months` must be greater than 0."
  }

  validation {
    condition = alltrue(flatten([
      for certificate in var.certificates : [
        for email in coalesce(try(certificate.certificate_policy.x509_certificate_properties.subject_alternative_names.emails, null), []) :
        can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", email))
      ]
    ]))
    error_message = "`certificates[*].certificate_policy.x509_certificate_properties.subject_alternative_names.emails` must contain valid email addresses."
  }
}