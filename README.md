<!-- BEGIN_TF_DOCS -->
# Azure Key Vault Certificate Management Terraform Module

Terraform module to manage Azure Key Vault certificate contacts, certificate issuers, and certificates.

## Permissions

To provision the Azure resources managed by this module, the identity running Terraform needs permissions such as:

- Key Vault certificate management (`Create`, `Get`, `List`, `Update`, `Import`, `Delete`). Recommended RBAC role: `Key Vault Certificates Officer` (scope: target Key Vault).
- Key Vault certificate issuer management (`ManageIssuers`, `GetIssuers`, `SetIssuers`, `DeleteIssuers`). Recommended RBAC role: `Key Vault Certificates Officer` (scope: target Key Vault).
- Key Vault certificate contacts management (`ManageContacts`). Recommended RBAC role: `Key Vault Certificates Officer` (scope: target Key Vault).

If your organization does not use least-privilege role separation, `Key Vault Administrator` at the target Key Vault scope also covers these operations.

Scope recommendation: assign these roles at the Key Vault resource scope; use Resource Group or Subscription scope only when required by your operating model.

## Authentications

Authentication to Azure can be configured using one of the following methods:

### Service Principal and Client Secret

Use an Azure AD service principal for non-interactive runs (CI/CD, automation).

You can configure this method in either of the following ways:

- **Inside the provider block**

  ```hcl
  provider "azurerm" {
    features {}

    subscription_id = "<subscription-id>"
    tenant_id       = "<tenant-id>"
    client_id       = "<client-id>"
    client_secret   = "<client-secret>"
  }
  ```

- **Using environment variables**

  - `ARM_SUBSCRIPTION_ID`
  - `ARM_TENANT_ID`
  - `ARM_CLIENT_ID`
  - `ARM_CLIENT_SECRET`

### Managed Service Identity

Use Managed Identity when Terraform runs on Azure-hosted compute (for example, Azure VM, VMSS, App Service, AKS).

- **Inside the provider block**

  ```hcl
  provider "azurerm" {
    features {}
    use_msi = true
  }
  ```

- **Using environment variables**

  - `ARM_USE_MSI=true`
  - `ARM_SUBSCRIPTION_ID`
  - `ARM_TENANT_ID` (optional in some environments, but recommended for clarity)

Documentation:

- [AzureRM provider authentication](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure)
- [Service Principal with client secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret)
- [Managed Service Identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/managed_service_identity)

## Features

- Configure Key Vault certificate contacts.
- Configure one or more certificate issuers.
- Create/import one or more certificates, including full certificate policy configuration.
- Configure optional resource timeouts and tags.

## Usage example

```hcl
module "keyvault_certificate_management" {
  source  = "app.terraform.io/benoitblais-hashicorp/terraform-azurerm-keyvault-cert-management/azurerm"
  version = "0.0.0"

  key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.KeyVault/vaults/kv-example"

  certificate_contacts = {
    contacts = [
      {
        email = "pki-ops@example.com"
        name  = "PKI Operations"
      }
    ]
  }

  certificate_issuers = [
    {
      name          = "digicert-issuer"
      provider_name = "DigiCert"
      account_id    = "0000"
      org_id        = "ExampleOrg"
    }
  ]

  certificates = [
    {
      name = "app-cert"
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
          key_usage          = ["digitalSignature", "keyEncipherment"]
          subject            = "CN=app.example.com"
          validity_in_months = 12
        }
      }
      tags = {
        environment = "dev"
      }
    }
  ]
}
```

## Documentation

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.13.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.64.0)

## Modules

No modules.

## Required Inputs

The following input variables are required:

### <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id)

Description: (Required) The ID of the Key Vault where certificate management resources should be created. Changing this forces a new resource to be created for applicable resources.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_certificate_contacts"></a> [certificate\_contacts](#input\_certificate\_contacts)

Description: 	(Optional) Configuration for Key Vault Certificate Contacts.  
		contacts : (Optional) One or more `contact` blocks as defined below.  
			email : (Required) E-mail address of the contact.  
			name : (Optional) Name of the contact.  
			phone : (Optional) Phone number of the contact.  
		timeouts : (Optional) A `timeouts` block to configure operation timeouts for create, read, update, and delete actions.  
			create : (Optional) Used when creating the Key Vault Certificate Contacts.  
			read : (Optional) Used when retrieving the Key Vault Certificate Contacts.  
			update : (Optional) Used when updating the Key Vault Certificate Contacts.  
			delete : (Optional) Used when deleting the Key Vault Certificate Contacts.

Type:

```hcl
object({
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
```

Default: `null`

### <a name="input_certificate_issuers"></a> [certificate\_issuers](#input\_certificate\_issuers)

Description: 	(Optional) A list of Key Vault Certificate Issuers.  
		key\_vault\_id : (Required) The ID of the Key Vault in which to create the Certificate Issuer.  
		name : (Required) The name which should be used for this Key Vault Certificate Issuer.  
		provider\_name : (Required) The name of the third-party Certificate Issuer.  
		account\_id : (Optional) The account number with the third-party Certificate Issuer.  
		admin : (Optional) One or more `admin` blocks as defined below.  
			email\_address : (Required) E-mail address of the admin.  
			first\_name : (Optional) First name of the admin.  
			last\_name : (Optional) Last name of the admin.  
			phone : (Optional) Phone number of the admin.  
		org\_id : (Optional) The ID of the organization as provided to the issuer.  
		password : (Optional) The password associated with the account and organization ID at the third-party Certificate Issuer.  
		timeouts : (Optional) A `timeouts` block to configure operation timeouts for create, read, update, and delete actions.  
			create : (Optional) Used when creating the Key Vault Certificate Issuer.  
			read : (Optional) Used when retrieving the Key Vault Certificate Issuer.  
			update : (Optional) Used when updating the Key Vault Certificate Issuer.  
			delete : (Optional) Used when deleting the Key Vault Certificate Issuer.

Type:

```hcl
list(object({
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
```

Default: `[]`

### <a name="input_certificates"></a> [certificates](#input\_certificates)

Description: 	(Optional) A list of Key Vault Certificates.  
		key\_vault\_id : (Required) The ID of the Key Vault where the Certificate should be created.  
		name : (Required) Specifies the name of the Key Vault Certificate.  
		certificate : (Optional) A `certificate` block, used to import an existing certificate.  
			contents : (Required) The base64-encoded certificate contents.  
			password : (Optional) The password associated with the certificate.  
		certificate\_policy : (Optional) A `certificate_policy` block.  
			issuer\_parameters : (Required) A `issuer_parameters` block.  
				name : (Required) The name of the Certificate Issuer.  
			key\_properties : (Required) A `key_properties` block.  
				curve : (Optional) Specifies the curve to use when creating an `EC` key. Possible values are `P-256`, `P-256K`, `P-384`, and `P-521`.  
				exportable : (Required) Is this certificate exportable?  
				key\_size : (Optional) The size of the key used in the certificate.  
				key\_type : (Required) Specifies the type of key. Possible values are `EC`, `EC-HSM`, `RSA`, `RSA-HSM` and `oct`.  
				reuse\_key : (Required) Is the key reusable?  
			lifetime\_action : (Optional) A `lifetime_action` block.  
				action : (Required) A `action` block.  
					action\_type : (Required) The Type of action to be performed when the lifetime trigger is triggered. Possible values include `AutoRenew` and `EmailContacts`.  
				trigger : (Required) A `trigger` block.  
					days\_before\_expiry : (Optional) The number of days before the Certificate expires that the action associated with this Trigger should run.  
					lifetime\_percentage : (Optional) The percentage at which during the Certificates Lifetime the action associated with this Trigger should run.  
			secret\_properties : (Required) A `secret_properties` block.  
				content\_type : (Required) The Content-Type of the Certificate, such as `application/x-pkcs12` for a PFX or `application/x-pem-file` for a PEM.  
			x509\_certificate\_properties : (Optional) A `x509_certificate_properties` block. Required when `certificate` block is not specified.  
				extended\_key\_usage : (Optional) A list of Extended/Enhanced Key Usages.  
				key\_usage : (Required) A list of uses associated with this Key.  
				subject : (Required) The Certificate's Subject.  
				subject\_alternative\_names : (Optional) A `subject_alternative_names` block.  
					dns\_names : (Optional) A list of alternative DNS names (FQDNs) identified by the Certificate.  
					emails : (Optional) A list of email addresses identified by this Certificate.  
					upns : (Optional) A list of User Principal Names identified by the Certificate.  
				validity\_in\_months : (Required) The Certificates Validity Period in Months.  
		tags : (Optional) A mapping of tags to assign to the resource.  
		timeouts : (Optional) A `timeouts` block to configure operation timeouts for create, read, update, and delete actions.  
			create : (Optional) Used when creating the Key Vault Certificate.  
			read : (Optional) Used when retrieving the Key Vault Certificate.  
			update : (Optional) Used when updating the Key Vault Certificate.  
			delete : (Optional) Used when deleting the Key Vault Certificate.

Type:

```hcl
list(object({
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
```

Default: `[]`

## Resources

The following resources are used by this module:

- [azurerm_key_vault_certificate.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate) (resource)
- [azurerm_key_vault_certificate_contacts.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate_contacts) (resource)
- [azurerm_key_vault_certificate_issuer.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate_issuer) (resource)

## Outputs

The following outputs are exported:

### <a name="output_certificate_contacts"></a> [certificate\_contacts](#output\_certificate\_contacts)

Description: The Key Vault Certificate Contacts resource if configured.

### <a name="output_certificate_contacts_id"></a> [certificate\_contacts\_id](#output\_certificate\_contacts\_id)

Description: The ID of the Key Vault Certificate Contacts resource if configured.

### <a name="output_certificate_issuers"></a> [certificate\_issuers](#output\_certificate\_issuers)

Description: Key Vault Certificate Issuer resources keyed by issuer name.

### <a name="output_certificate_issuers_ids"></a> [certificate\_issuers\_ids](#output\_certificate\_issuers\_ids)

Description: The IDs of Key Vault Certificate Issuer resources keyed by issuer name.

### <a name="output_certificates"></a> [certificates](#output\_certificates)

Description: Key Vault Certificate resources keyed by certificate name.

### <a name="output_certificates_ids"></a> [certificates\_ids](#output\_certificates\_ids)

Description: The IDs of Key Vault Certificate resources keyed by certificate name.

### <a name="output_certificates_resource_manager_ids"></a> [certificates\_resource\_manager\_ids](#output\_certificates\_resource\_manager\_ids)

Description: The versioned Resource Manager IDs of Key Vault Certificates keyed by certificate name.

### <a name="output_certificates_resource_manager_versionless_ids"></a> [certificates\_resource\_manager\_versionless\_ids](#output\_certificates\_resource\_manager\_versionless\_ids)

Description: The versionless Resource Manager IDs of Key Vault Certificates keyed by certificate name.

### <a name="output_certificates_secret_ids"></a> [certificates\_secret\_ids](#output\_certificates\_secret\_ids)

Description: The secret IDs associated with Key Vault Certificates keyed by certificate name.

### <a name="output_certificates_versions"></a> [certificates\_versions](#output\_certificates\_versions)

Description: The current versions of Key Vault Certificates keyed by certificate name.

<!-- markdownlint-enable -->
# External documentation

- [azurerm\_key\_vault\_certificate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate)
- [azurerm\_key\_vault\_certificate\_contacts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate\_contacts)
- [azurerm\_key\_vault\_certificate\_issuer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate\_issuer)
<!-- END_TF_DOCS -->