resource "azuread_group" "flyte_metadata" {
  display_name     = "${var.deploy_id}-flyte-metadata-group"
  security_enabled = true
  members = [
    azurerm_user_assigned_identity.flyte_controlplane.principal_id,
    azurerm_user_assigned_identity.flyte_dataplane.principal_id,
  ]
}

resource "azuread_group" "flyte_data" {
  display_name     = "${var.deploy_id}-flyte-data-group"
  security_enabled = true
  members = [
    azurerm_user_assigned_identity.flyte_dataplane.principal_id,
  ]
}

resource "azuread_group" "flyte_sas" {
  display_name     = "${var.deploy_id}-flyte-sas-group"
  security_enabled = true
  members = [
    azurerm_user_assigned_identity.flyte_dataplane.principal_id,
  ]
}
