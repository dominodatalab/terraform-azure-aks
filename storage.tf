resource "azurerm_storage_account" "domino" {
  name                     = replace(var.deploy_id, "/[_-]/", "")
  location                 = data.azurerm_resource_group.aks.location
  resource_group_name      = data.azurerm_resource_group.aks.name
  account_kind             = "StorageV2"
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  access_tier              = "Hot"
  min_tls_version          = "TLS1_2"
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  tags                     = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_storage_container" "domino_containers" {
  for_each = {
    for key, value in var.containers :
    key => value
  }

  name                  = "${var.deploy_id}-${each.key}"
  storage_account_name  = azurerm_storage_account.domino.name
  container_access_type = each.value.container_access_type
}

# Create shared store
resource "azurerm_storage_account" "domino_shared" {
  name                     = "${replace(var.deploy_id, "/[_-]/", "")}${"shared"}"
  location                 = data.azurerm_resource_group.aks.location
  resource_group_name      = data.azurerm_resource_group.aks.name
  account_kind             = "StorageV2"
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  access_tier              = "Hot"
  min_tls_version          = "TLS1_2"
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  tags                     = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# Create a fileshare for private storage
resource "azurerm_storage_share" "shared_store" {
  name                 = "shared"
  storage_account_name = azurerm_storage_account.domino_shared.name
  quota                = 100
}

# Assign identity permissins on fileshare
resource "azurerm_role_assignment" "identity_assign_aks" {
  count                = var.private_cluster_enabled ? 1 : 0
  scope                = azurerm_storage_account.domino_shared.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_assigned_identity[0].principal_id
  depends_on = [
    azurerm_user_assigned_identity.aks_assigned_identity
  ]
}

# Create a private endpoint for the storages
module "domino_blobs_ep" {
  count                 = var.private_cluster_enabled ? 1 : 0
  source                = "./modules/private_endpoint"
  resource_id           = azurerm_storage_account.domino.id
  nic_name              = "blob-${var.deploy_id}"
  private_endpoint_name = "blob-${var.deploy_id}"
  private_dns_zone      = "privatelink.blob.core.windows.net"
  private_dns_zone_id   = "/subscriptions/de806df8-4359-4802-b814-b8a7699cfaa5/resourceGroups/hub-network/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
  sub_resource          = "blob"
  location              = data.azurerm_resource_group.aks.location
  resource_group_name   = data.azurerm_resource_group.aks.name
  subnet_id             = data.azurerm_subnet.aks_subnet[0].id
}

module "domino_shared_ep" {
  count                 = var.private_cluster_enabled ? 1 : 0
  source                = "./modules/private_endpoint"
  resource_id           = azurerm_storage_account.domino_shared.id
  nic_name              = "shared-${var.deploy_id}"
  private_endpoint_name = "shared-${var.deploy_id}"
  private_dns_zone      = "privatelink.file.core.windows.net"
  private_dns_zone_id   = "/subscriptions/de806df8-4359-4802-b814-b8a7699cfaa5/resourceGroups/hub-network/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net"
  sub_resource          = "file"
  location              = data.azurerm_resource_group.aks.location
  resource_group_name   = data.azurerm_resource_group.aks.name
  subnet_id             = data.azurerm_subnet.aks_subnet[0].id
}