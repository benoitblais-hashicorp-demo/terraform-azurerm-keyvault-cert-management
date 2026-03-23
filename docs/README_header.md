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
