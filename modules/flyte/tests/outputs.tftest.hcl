mock_provider "azuread" {}
mock_provider "azurerm" {}

run "test_outputs" {
  command = plan

  assert {
    condition     = output.flyte_metadata_container_name == azurerm_storage_container.flyte_metadata.name
    error_message = "Incorrect Flyte metadata container name output"
  }

  assert {
    condition     = output.flyte_data_container_name == azurerm_storage_container.flyte_data.name
    error_message = "Incorrect Flyte data container name output"
  }
}
