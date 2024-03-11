output "flyte_metadata_container_name" {
  value       = azurerm_storage_container.flyte_metadata.name
  description = "Flyte metadata storage container name"
}

output "flyte_data_container_name" {
  value       = azurerm_storage_container.flyte_data.name
  description = "Flyte data storage container name"
}

output "flyte_controlplane_client_id" {
  value       = azurerm_user_assigned_identity.this["flyte_controlplane"].client_id
  description = "Flyte controlplane client id"
}

output "flyte_dataplane_client_id" {
  value       = azurerm_user_assigned_identity.this["flyte_dataplane"].client_id
  description = "Flyte dataplane client id"
}
