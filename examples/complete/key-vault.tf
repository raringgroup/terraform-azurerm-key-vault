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
##  examples/complete/key-vault.tf
##
##  Creates a resource group and an RBAC-authorized key vault. Purge protection
##  is off so the example can be destroyed and re-created.
## ----------------------------------------------------------------------------

## Resource Group
resource "azurerm_resource_group" "this" {
  location = var.region
  name     = "${module.context.id}-rg"
  tags     = module.context.tags
}


## Key Vault
module "key_vault" {
  source  = "../../"
  context = module.context.self

  location                      = azurerm_resource_group.this.location
  public_network_access_enabled = true
  purge_protection_enabled      = false
  rbac_authorization_enabled    = true
  resource_group_name           = azurerm_resource_group.this.name
  sku_name                      = "standard"
  soft_delete_retention_days    = 7

  access_policies  = {}
  role_assignments = {}

  network_acls = {
    bypass                     = "AzureServices"
    default_action             = "Allow"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
}
