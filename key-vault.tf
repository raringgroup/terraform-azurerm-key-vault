## ----------------------------------------------------------------------------
## Copyright 2026 Raring Group LLC
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
## ----------------------------------------------------------------------------
##
##  modules/key-vault/key-vault.tf
##
##  Azure Key Vault supporting Azure RBAC or access policies, with role assignments.
## ----------------------------------------------------------------------------

## Key Vault Context
module "key_vault_context" {
  source  = "../null-context"
  context = module.context.self

  attributes      = ["kv"]
  id_length_limit = 24
}


## Key Vault
resource "azurerm_key_vault" "this" {
  count = module.key_vault_context.enabled ? 1 : 0

  location                      = var.location
  name                          = module.key_vault_context.id
  public_network_access_enabled = var.public_network_access_enabled
  purge_protection_enabled      = var.purge_protection_enabled
  rbac_authorization_enabled    = var.rbac_authorization_enabled
  resource_group_name           = var.resource_group_name
  sku_name                      = var.sku_name
  soft_delete_retention_days    = var.soft_delete_retention_days
  tags                          = module.key_vault_context.tags
  tenant_id                     = local.tenant_id

  network_acls {
    bypass                     = var.network_acls.bypass
    default_action             = var.network_acls.default_action
    ip_rules                   = var.network_acls.ip_rules
    virtual_network_subnet_ids = var.network_acls.virtual_network_subnet_ids
  }

  lifecycle {
    precondition {
      condition     = !(var.rbac_authorization_enabled && length(var.access_policies) > 0)
      error_message = "access_policies can only be set when rbac_authorization_enabled is false."
    }
  }
}


## Role Assignments
resource "azurerm_role_assignment" "this" {
  for_each = module.key_vault_context.enabled ? var.role_assignments : {}

  principal_id         = each.value.principal_id
  role_definition_name = each.value.role_definition_name
  scope                = azurerm_key_vault.this[0].id
}


## Access Policies
resource "azurerm_key_vault_access_policy" "this" {
  for_each = module.key_vault_context.enabled ? var.access_policies : {}

  certificate_permissions = each.value.certificate_permissions
  key_permissions         = each.value.key_permissions
  key_vault_id            = azurerm_key_vault.this[0].id
  object_id               = each.value.object_id
  secret_permissions      = each.value.secret_permissions
  tenant_id               = local.tenant_id
}
