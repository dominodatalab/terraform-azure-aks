resource "azurerm_role_definition" "flyte_metadata_role" {
  name  = "${var.deploy_id}-flyte-metadata"
  scope = azurerm_storage_container.flyte_metadata.resource_manager_id
  permissions {
    data_actions = [
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/add/action",
    ]
  }
}

resource "azurerm_role_definition" "flyte_data_role" {
  name  = "${var.deploy_id}-flyte-data"
  scope = azurerm_storage_container.flyte_data.resource_manager_id
  permissions {
    data_actions = [
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/add/action",
    ]
  }
}

# Because the Get User Delegation Key operation acts at the level of the storage account, the
# Microsoft.Storage/storageAccounts/blobServices/generateUserDelegationKey action must be scoped at the level
# of the storage account, the resource group, or the subscription.
# https://learn.microsoft.com/en-us/rest/api/storageservices/get-user-delegation-key
#
resource "azurerm_role_definition" "flyte_sas_role" {
  name  = "${var.deploy_id}-flyte-sas"
  scope = var.azurerm_storage_account_id
  permissions {
    actions = [
      "Microsoft.Storage/storageAccounts/blobServices/generateUserDelegationKey/action"
    ]
  }
}

resource "azurerm_role_assignment" "flyte_metadata_role_assignment" {
  scope              = azurerm_storage_container.flyte_metadata.resource_manager_id
  role_definition_id = azurerm_role_definition.flyte_metadata_role.role_definition_resource_id
  principal_id       = azuread_group.flyte_metadata_group.object_id
}

resource "azurerm_role_assignment" "flyte_data_role_assignment" {
  scope              = azurerm_storage_container.flyte_data.resource_manager_id
  role_definition_id = azurerm_role_definition.flyte_data_role.role_definition_resource_id
  principal_id       = azuread_group.flyte_data_group.object_id
}

resource "azurerm_role_assignment" "flyte_sas_role_assignment" {
  scope              = var.azurerm_storage_account_id
  role_definition_id = azurerm_role_definition.flyte_sas_role.role_definition_resource_id
  principal_id       = azuread_group.flyte_sas_group.object_id
}
