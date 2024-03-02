output "aks" {
  description = <<EOF
  Flyte AKS info
  ```
  {
    metadata_container_name = Metadata storage container name
    data_container_name = Data storage container name
    controlplane_client_id = Controlplane client id
    dataplane_client_id = Dataplane client id
  }
  ```
  EOF
  value = {
    metadata_container_name = azurerm_storage_container.flyte_metadata.name
    data_container_name     = azurerm_storage_container.flyte_data.name
    controlplane_client_id  = azurerm_user_assigned_identity.flyte_controlplane.client_id
    dataplane_client_id     = azurerm_user_assigned_identity.flyte_dataplane.client_id
  }
}
