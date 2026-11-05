# key-vault

Creates an Azure Key Vault that supports both authorization models, Azure RBAC and access policies, selected by `rbac_authorization_enabled`. It also manages optional role assignments (RBAC) or access policies on the vault, named through the SevenPico context module.

## Requirements

| Name | Version |
|------|---------|
| terraform | `>= 1.3.0` |
| azurerm | `>= 4.0.0, < 5.0.0` |

## Module Priority

No SevenPico, SevenPicoForks or CloudPosse module exists for Azure Key Vault, so the module uses `azurerm_key_vault`, `azurerm_role_assignment` and `azurerm_key_vault_access_policy` directly. The vault name is limited to 24 characters, the Azure maximum. The tenant ID is read from `azurerm_client_config` and is never an input. Naming and the enabled flag come from the context module. `_context.tf` declares the root context (`SevenPico/context/null` `2.0.0`); child contexts use the local `../null-context` module.

## Inputs

All inputs are required (no defaults). Context inputs (`enabled`, `namespace`, `environment`, `stage`, `name`, `attributes`, `tags`, ...) are declared in `_context.tf`.

| Name | Type | Description |
|------|------|-------------|
| resource_group_name | `string` | Resource group that holds the vault |
| location | `string` | Azure region |
| sku_name | `string` | `standard` or `premium` |
| soft_delete_retention_days | `number` | Retention for deleted vaults and objects (7 to 90) |
| purge_protection_enabled | `bool` | Purge protection; cannot be turned off once enabled |
| public_network_access_enabled | `bool` | Accept traffic from the public network |
| rbac_authorization_enabled | `bool` | `true` uses Azure RBAC, `false` uses access policies |
| access_policies | `map(object)` | Access policies: `object_id`, `certificate_permissions`, `key_permissions`, `secret_permissions`. Must be empty when RBAC is enabled |
| network_acls | `object` | `bypass`, `default_action`, `ip_rules`, `virtual_network_subnet_ids` |
| role_assignments | `map(object)` | RBAC assignments on the vault: `principal_id`, `role_definition_name`. Only effective when RBAC is enabled |

## Outputs

| Name | Description |
|------|-------------|
| id | Key vault ID (null when disabled) |
| name | Key vault name (null when disabled) |
| vault_uri | Key vault URI (null when disabled) |

## Usage

```hcl
terraform {
  source = "git::<repo-url>//modules/key-vault?ref=key-vault-v<version>"
}

dependency "resource_group" {
  config_path = "../resource-group"
}

dependency "app_service" {
  config_path = "../app-service"
}

inputs = {
  enabled     = true
  namespace   = "<namespace>"
  environment = "<environment>"
  stage       = "<stage>"
  name        = "<name>"

  location                      = dependency.resource_group.outputs.location
  public_network_access_enabled = true
  purge_protection_enabled      = true
  rbac_authorization_enabled    = true
  resource_group_name           = dependency.resource_group.outputs.name
  sku_name                      = "standard"
  soft_delete_retention_days    = 90

  access_policies = {}

  network_acls = {
    bypass                     = "AzureServices"
    default_action             = "Allow"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }

  role_assignments = {
    "app-secrets-user" = {
      principal_id         = dependency.app_service.outputs.principal_id
      role_definition_name = "Key Vault Secrets User"
    }
  }
}
```

## License

Apache License 2.0. Copyright 2026 Raring Group LLC.
