resource "azurerm_role_definition" "flyte_storage_access" {
  name  = "flyte-storage-access"
  scope = azurerm_storage_container.flyte_metadata.resource_manager_id
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
    azurerm_storage_container.flyte_metadata.resource_manager_id,
    azurerm_storage_container.flyte_data.resource_manager_id,
  ]
}

resource "azurerm_role_assignment" "flyte_metadata_access" {
  scope              = azurerm_storage_container.flyte_metadata.resource_manager_id
  role_definition_id = azurerm_role_definition.flyte_storage_access.role_definition_resource_id
  principal_id       = azuread_group.flyte_metadata_access.object_id
}

resource "azurerm_role_assignment" "flyte_data_access" {
  scope              = azurerm_storage_container.flyte_data.resource_manager_id
  role_definition_id = azurerm_role_definition.flyte_storage_access.role_definition_resource_id
  principal_id       = azuread_group.flyte_data_access.object_id
}
