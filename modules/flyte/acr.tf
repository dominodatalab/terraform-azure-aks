resource "azurerm_role_assignment" "flyte_controlplane_acr" {
  scope                = var.azurerm_container_registry.domino.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.flyte_controlplane.principal_id
}

resource "azurerm_role_assignment" "flyte_dataplane_acr" {
  scope                = var.azurerm_container_registry.domino.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.flyte_dataplane.principal_id
}
