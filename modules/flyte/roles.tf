resource "azurerm_role_definition" "flyte_storage_access" {
  name  = "Flyte storage access"
  scope = azurerm_storage_container.flyte_metadata.id
  permissions {
    actions = [
      "Microsoft.Storage/storageAccounts/blobServices/containers/read",
      "Microsoft.Storage/storageAccounts/blobServices/generateUserDelegationKey/action"
    ]
    data_actions = [
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write",
    ]
  }
  assignable_scopes = [
    azurerm_storage_container.flyte_metadata.id,
    azurerm_storage_container.flyte_data.id,
  ]
}

resource "azurerm_role_assignment" "flyte_metadata_access" {
  scope              = azurerm_storage_container.flyte_metadata.id
  role_definition_id = azurerm_role_definition.flyte_storage_access
  principal_id       = azuread_group.flyte_metadata_access.id
}

resource "azurerm_role_assignment" "flyte_data_access" {
  scope              = azurerm_storage_container.flyte_data.id
  role_definition_id = azurerm_role_definition.flyte_storage_access
  principal_id       = azuread_group.flyte_data_access.id
}
