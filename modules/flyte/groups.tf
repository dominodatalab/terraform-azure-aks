resource "azuread_group" "flyte_metadata_group" {
  display_name     = "Flyte metadata"
  security_enabled = true
  members = [
    azurerm_user_assigned_identity.this["flyte_controlplane"].principal_id,
    azurerm_user_assigned_identity.this["flyte_dataplane"].principal_id,
  ]
}

resource "azuread_group" "flyte_data_group" {
  display_name     = "Flyte data"
  security_enabled = true
  members = [
    azurerm_user_assigned_identity.this["flyte_dataplane"].principal_id,
  ]
}

resource "azuread_group" "flyte_sas_group" {
  display_name     = "Flyte SAS"
  security_enabled = true
  members = [
    azurerm_user_assigned_identity.this["flyte_dataplane"].principal_id,
  ]
}
