resource "azurerm_storage_account" "flyte" {
  name                     = join("", [replace(var.deploy_id, "/[_-]/", ""), "flyte"])
  location                 = var.resource_group_location
  resource_group_name      = var.resource_group_name
  account_kind             = "StorageV2"
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  access_tier              = "Hot"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
  is_hns_enabled           = true
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_storage_container" "flyte_metadata" {
  name                  = "${var.deploy_id}-flyte-metadata"
  storage_account_name  = azurerm_storage_account.flyte.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "flyte_data" {
  name                  = "${var.deploy_id}-flyte-data"
  storage_account_name  = azurerm_storage_account.flyte.name
  container_access_type = "private"
}

module "domino_shared_ep" {
  count                 = 1
  source                = "/Users/vdhawan/Documents/Domino/git/terraform-azure-aks/modules/private_endpoint"
  resource_id           = azurerm_storage_account.flyte.id
  nic_name              = "flyte-${var.deploy_id}"
  private_endpoint_name = "flyte-${var.deploy_id}"
  private_dns_zone      = "privatelink.blob.core.windows.net"
  private_dns_zone_id   = "/subscriptions/de806df8-4359-4802-b814-b8a7699cfaa5/resourceGroups/hub-network/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
  sub_resource          = "blob"
  location              = var.resource_group_location
  resource_group_name   = var.resource_group_name
  subnet_id             = "/subscriptions/de806df8-4359-4802-b814-b8a7699cfaa5/resourceGroups/domino-spoke-test/providers/Microsoft.Network/virtualNetworks/domino-spoke-1/subnets/default"
}