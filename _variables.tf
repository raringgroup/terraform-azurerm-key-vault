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
##  modules/key-vault/_variables.tf
##
##  Input variables for the Key Vault module.
## ----------------------------------------------------------------------------

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group that holds the key vault"
}

variable "location" {
  type        = string
  description = "Azure region where the key vault is created"
}

variable "sku_name" {
  type        = string
  description = "Key vault SKU: standard or premium"
}

variable "soft_delete_retention_days" {
  type        = number
  description = "Days a deleted vault or object is retained before purge (7 to 90)"
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Whether purge protection is enabled; it cannot be turned off once enabled"
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether the vault accepts traffic from the public network"
}

variable "rbac_authorization_enabled" {
  type        = bool
  description = "Whether the vault uses Azure RBAC (true) or access policies (false) to authorize data-plane access"
}

variable "access_policies" {
  type = map(object({
    object_id               = string
    certificate_permissions = list(string)
    key_permissions         = list(string)
    secret_permissions      = list(string)
  }))
  description = "Access policies keyed by a stable name; only allowed when rbac_authorization_enabled is false"
}

variable "network_acls" {
  type = object({
    bypass                     = string
    default_action             = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  description = "Network rules: bypass (AzureServices or None), default_action (Allow or Deny), allowed IP ranges and allowed subnet IDs"
}

variable "role_assignments" {
  type = map(object({
    principal_id         = string
    role_definition_name = string
  }))
  description = "Azure RBAC role assignments on the vault, keyed by a stable name (e.g. Key Vault Secrets User for an app identity)"
}
