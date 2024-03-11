resource "azurerm_storage_container" "flyte_metadata" {
  name                  = "${var.deploy_id}-flyte-metadata"
  storage_account_name  = var.azurerm_storage_account_name
  container_access_type = "private"
}

resource "azurerm_storage_container" "flyte_data" {
  name                  = "${var.deploy_id}-flyte-data"
  storage_account_name  = var.azurerm_storage_account_name
  container_access_type = "private"
}
