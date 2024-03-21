mock_provider "azuread" {}
mock_provider "azurerm" {}

run "test_roles" {
  command = plan

  assert {
    condition     = azurerm_role_definition.flyte_sas_role.scope == var.azurerm_storage_account_id
    error_message = "Incorrect Flyte SAS role scope"
  }

  assert {
    condition     = azurerm_role_assignment.flyte_sas_role_assignment.scope == var.azurerm_storage_account_id
    error_message = "Incorrect Flyte SAS role assignment scope"
  }
}
