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
##  modules/key-vault/examples/complete/_outputs.tf
##
##  Outputs of the example.
## ----------------------------------------------------------------------------

output "id" {
  value = module.key_vault.id
}

output "name" {
  value = module.key_vault.name
}

output "vault_uri" {
  value = module.key_vault.vault_uri
}
