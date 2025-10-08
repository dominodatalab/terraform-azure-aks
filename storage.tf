#########################################################################
################################# Locals ################################
#########################################################################
locals {
  # Set the value of private_blob_enabled based on private_cluster_enabled
  private_blob_enabled = var.private_cluster_enabled ? true : false

  # Set the value of private_shared_enabled based on private_cluster_enabled
  private_shared_enabled = var.private_cluster_enabled ? true : false
}
#########################################################################
############################ Storage Account ############################
#########################################################################
# Create Domino Blob Storage Account
resource "azurerm_storage_account" "domino" {
  name                            = replace(var.deploy_id, "/[_-]/", "")
  location                        = data.azurerm_resource_group.aks.location
  resource_group_name             = data.azurerm_resource_group.aks.name
  public_network_access_enabled   = local.private_blob_enabled ? false : null
  allow_nested_items_to_be_public = local.private_blob_enabled ? false : null
  local_user_enabled              = local.private_blob_enabled ? false : null
  account_kind                    = "StorageV2"
  account_tier                    = var.storage_account_tier
  account_replication_type        = var.storage_account_replication_type
  access_tier                     = "Hot"
  min_tls_version                 = "TLS1_2"
  tags                            = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

  dynamic "share_properties" {
    for_each = local.private_blob_enabled ? [1] : []
    content {
      retention_policy {
        days = 14
      }
    }
  }

}
# Create Domino Shared Storage Account
resource "azurerm_storage_account" "domino_shared" {
  name                            = "${replace(var.deploy_id, "/[_-]/", "")}${"shared"}"
  location                        = data.azurerm_resource_group.aks.location
  resource_group_name             = data.azurerm_resource_group.aks.name
  public_network_access_enabled   = local.private_shared_enabled ? false : null
  allow_nested_items_to_be_public = local.private_shared_enabled ? false : null
  local_user_enabled              = local.private_shared_enabled ? false : null
  account_kind                    = "StorageV2"
  account_tier                    = var.storage_account_tier
  account_replication_type        = var.storage_account_replication_type
  access_tier                     = "Hot"
  min_tls_version                 = "TLS1_2"
  tags                            = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

  dynamic "share_properties" {
    for_each = local.private_shared_enabled ? [1] : []
    content {
      retention_policy {
        days = 14
      }
    }
  }

}
#########################################################################
########################## Private DNS Zone #############################
#########################################################################
# Create a Private DNS Zone for the Storage Account Blob service
resource "azurerm_private_dns_zone" "blob_private_dns_zone" {
  count               = local.private_blob_enabled ? 1 : 0
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = data.azurerm_resource_group.aks.name
}
# link the dns private zone to the AKS VNET
resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_blob_vnet_link" {
  count                 = local.private_blob_enabled ? 1 : 0
  name                  = "blob-vnet-dns-link"
  resource_group_name   = data.azurerm_resource_group.aks.name
  private_dns_zone_name = azurerm_private_dns_zone.blob_private_dns_zone[0].name
  virtual_network_id    = data.azurerm_virtual_network.aks_vnet[0].id
}
# Create a Private DNS Zone for the Storage Account shared service
resource "azurerm_private_dns_zone" "shared_private_dns_zone" {
  count               = local.private_shared_enabled ? 1 : 0
  name                = "privatelink.file.core.windows.net"
  resource_group_name = data.azurerm_resource_group.aks.name
}
# link the dns private zone to the AKS VNET
resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_shared_vnet_link" {
  count                 = local.private_shared_enabled ? 1 : 0
  name                  = "shared-vnet-dns-link"
  resource_group_name   = data.azurerm_resource_group.aks.name
  private_dns_zone_name = azurerm_private_dns_zone.shared_private_dns_zone[0].name
  virtual_network_id    = data.azurerm_virtual_network.aks_vnet[0].id
}
#########################################################################
########################## Private EndPoint #############################
#########################################################################
# Create a private endpoint for the Blob Storage Account
module "domino_blob_ep" {
  count                 = local.private_blob_enabled ? 1 : 0
  source                = "./modules/private_endpoint"
  resource_id           = azurerm_storage_account.domino.id
  nic_name              = "sa-blob-${var.deploy_id}"
  private_endpoint_name = "sa-blob-${var.deploy_id}"
  private_dns_zone      = azurerm_private_dns_zone.blob_private_dns_zone[0].name
  private_dns_zone_id   = azurerm_private_dns_zone.blob_private_dns_zone[0].id
  sub_resource          = "blob"
  location              = data.azurerm_resource_group.aks.location
  resource_group_name   = data.azurerm_resource_group.aks.name
  subnet_id             = data.azurerm_subnet.aks_subnet[0].id
}
# Create a private endpoint for the fileshare Storage Account
module "domino_shared_ep" {
  count                 = local.private_shared_enabled ? 1 : 0
  source                = "./modules/private_endpoint"
  resource_id           = azurerm_storage_account.domino_shared.id
  nic_name              = "sa-shared-${var.deploy_id}"
  private_endpoint_name = "sa-shared-${var.deploy_id}"
  private_dns_zone      = azurerm_private_dns_zone.shared_private_dns_zone[0].name
  private_dns_zone_id   = azurerm_private_dns_zone.shared_private_dns_zone[0].id
  sub_resource          = "file"
  location              = data.azurerm_resource_group.aks.location
  resource_group_name   = data.azurerm_resource_group.aks.name
  subnet_id             = data.azurerm_subnet.aks_subnet[0].id
  depends_on            = [azurerm_storage_account.domino_shared]
}
#########################################################################
############################ Network rules ##############################
#########################################################################
# Create a storage account network rule to authorize access to shared from private endpoint
resource "azurerm_storage_account_network_rules" "domino_shared_rules" {
  count                      = local.private_shared_enabled ? 1 : 0
  storage_account_id         = azurerm_storage_account.domino_shared.id
  default_action             = "Deny"
  bypass                     = ["AzureServices"]
  virtual_network_subnet_ids = [data.azurerm_subnet.aks_subnet[0].id]
  depends_on                 = [module.domino_shared_ep]
}
# Create a storage account network rule to authorize access to blob from private endpoint
resource "azurerm_storage_account_network_rules" "domino_blob_rules" {
  count                      = local.private_blob_enabled ? 1 : 0
  storage_account_id         = azurerm_storage_account.domino.id
  default_action             = "Deny"
  bypass                     = ["AzureServices"]
  virtual_network_subnet_ids = [data.azurerm_subnet.aks_subnet[0].id]
  depends_on                 = [module.domino_blob_ep]
}
#########################################################################
##################### Storage Account Containers ########################
#########################################################################
locals {
  # Merge workspace audit containers with standard containers when enabled
  all_containers = merge(
    var.containers,
    var.workspace_audit.enabled ? {
      (var.workspace_audit.events_container_name) = {
        container_access_type = var.workspace_audit.container_access_type
      }
      (var.workspace_audit.events_archive_container_name) = {
        container_access_type = var.workspace_audit.container_access_type
      }
    } : {}
  )
}

resource "azurerm_storage_container" "domino_containers" {
  for_each = {
    for key, value in local.all_containers :
    key => value
  }

  name                  = "${var.deploy_id}-${each.key}"
  storage_account_name  = azurerm_storage_account.domino.name
  container_access_type = each.value.container_access_type
}
#########################################################################
###################### Storage Account Fileshare ########################
#########################################################################
# Create a fileshare for private storage
resource "azurerm_storage_share" "shared_store" {
  name                 = "shared"
  storage_account_name = azurerm_storage_account.domino_shared.name
  quota                = 100
}
