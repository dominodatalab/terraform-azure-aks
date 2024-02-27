output "info" {
  description = "Flyte info"
  value = {
    aks = {
      metadata_container     = azurerm_storage_container.flyte_metadata.name
      data_container         = azurerm_storage_container.flyte_data.name
      controlplane_client_id = azurerm_user_assigned_identity.flyte_controlplane.client_id
      dataplane_client_id    = azurerm_user_assigned_identity.flyte_dataplane.client_id
    }
  }
}
