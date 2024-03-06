resource "azuread_group" "flyte_metadata_access" {
  display_name     = "Flyte metadata access"
  security_enabled = true
  members = [
    azurerm_user_assigned_identity.flyte_controlplane.id,
  ]
}

resource "azuread_group" "flyte_data_access" {
  display_name     = "Flyte data access"
  security_enabled = true
  members = [
    azurerm_user_assigned_identity.flyte_controlplane.id,
    azurerm_user_assigned_identity.flyte_dataplane.id,
  ]
}
