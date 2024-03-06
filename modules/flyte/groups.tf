resource "azuread_group" "flyte_metadata_access" {
  display_name     = "Flyte metadata access"
  security_enabled = true
  members = [
    azurerm_user_assigned_identity.flyte_controlplane.principal_id,
    azurerm_user_assigned_identity.flyte_dataplane.principal_id,
  ]
}

resource "azuread_group" "flyte_data_access" {
  display_name     = "Flyte data access"
  security_enabled = true
  members = [
    azurerm_user_assigned_identity.flyte_dataplane.principal_id,
  ]
}
