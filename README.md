# terraform-azurerm-key-vault

Creates an Azure Key Vault that supports both authorization models, Azure RBAC and access policies, selected by `rbac_authorization_enabled`. It also manages optional role assignments (RBAC) or access policies on the vault. Everything is named through the `null-context` module.

Part of the [Raring Group](https://github.com/raringgroup) Terraform module library.

## Usage

```hcl
module "key_vault" {
  source = "git::https://github.com/raringgroup/terraform-azurerm-key-vault.git?ref=v0.1.0"

  context = module.context.self

  location                      = "<azure-region>"
  public_network_access_enabled = true
  purge_protection_enabled      = true
  rbac_authorization_enabled    = true
  resource_group_name           = "<resource-group>"
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
      principal_id         = "<principal-id>"
      role_definition_name = "Key Vault Secrets User"
    }
  }
}
```

Naming and tagging come from [`terraform-null-context`](https://github.com/raringgroup/terraform-null-context). Add `_context.tf` to the calling configuration and pass `context = module.context.self`.

See [`examples/`](examples/) for complete, runnable configurations.

## Requirements, providers, inputs, outputs

### Design notes

The module uses `azurerm_key_vault`, `azurerm_role_assignment` and `azurerm_key_vault_access_policy` directly. The vault name is limited to 24 characters, the Azure maximum. The tenant ID is read from `azurerm_client_config` and is never an input. `_context.tf` declares the root context; it and the child contexts use `git::https://github.com/raringgroup/terraform-null-context.git?ref=v0.1.0`.

### Requirements

| Name | Version |
|------|---------|
| terraform | `>= 1.3.0` |
| azurerm | `>= 4.0.0, < 5.0.0` |

### Naming

The vault name is built by `null-context` from the context inputs plus the type token `kv`. These inputs produce `kv-example-dev-app` (18 characters, under the 24-character limit):

```hcl
inputs = {
  namespace   = "example"
  environment = "dev"
  name        = "app"
  label_order = ["attributes", "namespace", "environment", "name"]
}
```

### Inputs

All inputs are required (no defaults). Context inputs (`enabled`, `namespace`, `environment`, `stage`, `name`, `attributes`, `tags`, ...) are declared in `_context.tf`.

| Name | Type | Description |
|------|------|-------------|
| resource_group_name | `string` | Resource group that holds the vault |
| location | `string` | Azure region |
| sku_name | `string` | `standard` or `premium` |
| soft_delete_retention_days | `number` | Retention for deleted vaults and objects, 7 to 90 |
| purge_protection_enabled | `bool` | Purge protection; cannot be turned off once enabled |
| public_network_access_enabled | `bool` | Accept traffic from the public network |
| rbac_authorization_enabled | `bool` | `true` uses Azure RBAC, `false` uses access policies |
| access_policies | `map(object)` | Access policies: `object_id`, `certificate_permissions`, `key_permissions`, `secret_permissions`. Must be empty when RBAC is enabled |
| network_acls | `object` | `bypass`, `default_action`, `ip_rules`, `virtual_network_subnet_ids` |
| role_assignments | `map(object)` | RBAC assignments on the vault: `principal_id`, `role_definition_name`. Only effective when RBAC is enabled |

### Outputs

| Name | Description |
|------|-------------|
| id | Key vault ID (null when disabled) |
| name | Key vault name (null when disabled) |
| vault_uri | Key vault URI (null when disabled) |

## Versioning

Releases follow semantic versioning and are tagged `vX.Y.Z`. Pin `?ref=` to a tag.

## Contributing

Work happens on `develop` through feature branches and pull requests. See the Raring Group gitflow standards.

## License

Apache-2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).

`_context.tf` is derived from Cloud Posse's [terraform-null-label](https://github.com/cloudposse/terraform-null-label).
