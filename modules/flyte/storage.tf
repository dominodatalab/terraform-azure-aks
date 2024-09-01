#########################################################################
################################# Locals ################################
#########################################################################
locals {
  # Set the value of private_flyte_enabled based on private_cluster_enabled
  private_flyte_enabled = var.private_cluster_enabled ? true : false
}
#########################################################################
################################# Data ##################################
#########################################################################
# Retrieve AKS vnet resource group
data "azurerm_resource_group" "aks" {
  name = reverse(split("/", var.aks_vnet_rg_name))[0]
}
# Retrieve AKS subnet
data "azurerm_subnet" "aks_subnet" {
  count                = var.private_cluster_enabled ? 1 : 0
  name                 = var.aks_subnet_name
  virtual_network_name = var.aks_vnet_name
  resource_group_name  = var.aks_vnet_rg_name
}
# Retrieve AKS vnet
data "azurerm_virtual_network" "aks_vnet" {
  count               = var.private_cluster_enabled ? 1 : 0
  name                = var.aks_vnet_name
  resource_group_name = var.aks_vnet_rg_name
}
#########################################################################
############################ Storage Account ############################
#########################################################################
# Create Domino Flyte Storage Account
resource "azurerm_storage_account" "flyte" {
  name                            = join("", [replace(var.deploy_id, "/[_-]/", ""), "flyte"])
  location                        = var.resource_group_location
  resource_group_name             = var.resource_group_name
  account_kind                    = "StorageV2"
  account_tier                    = var.storage_account_tier
  account_replication_type        = var.storage_account_replication_type
  access_tier                     = "Hot"
  min_tls_version                 = "TLS1_2"
  tags                            = var.tags
  is_hns_enabled                  = true
  public_network_access_enabled   = local.private_flyte_enabled ? false : null
  allow_nested_items_to_be_public = local.private_flyte_enabled ? false : null
  local_user_enabled              = local.private_flyte_enabled ? false : null

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

  dynamic "share_properties" {
    for_each = local.private_flyte_enabled ? [1] : []
    content {
      retention_policy {
        days = 14
      }
    }
  }

}
#########################################################################
##################### Storage Account Containers ########################
#########################################################################
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
#########################################################################
########################## Private DNS Zone #############################
#########################################################################
# Create a Private DNS Zone for the Storage Account Blob service
resource "azurerm_private_dns_zone" "flyte_private_dns_zone" {
  count               = local.private_flyte_enabled ? 1 : 0
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.aks_vnet_rg_name
}
# link the dns private zone to the AKS VNET
resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_flyte_vnet_link" {
  count                 = local.private_flyte_enabled ? 1 : 0
  name                  = "flyte-vnet-dns-link"
  resource_group_name   = var.aks_vnet_rg_name
  private_dns_zone_name = azurerm_private_dns_zone.flyte_private_dns_zone[0].name
  virtual_network_id    = data.azurerm_virtual_network.aks_vnet[0].id
}
#########################################################################
########################## Private EndPoint #############################
#########################################################################
# Create a private endpoint for the Flyte Blob Storage Account
module "domino_flyte_ep" {
  count                 = local.private_flyte_enabled ? 1 : 0
  source                = "../private_endpoint"
  resource_id           = azurerm_storage_account.flyte.id
  nic_name              = "sa-flyte-${var.deploy_id}"
  private_endpoint_name = "sa-flyte-${var.deploy_id}"
  private_dns_zone      = azurerm_private_dns_zone.flyte_private_dns_zone[0].name
  private_dns_zone_id   = azurerm_private_dns_zone.flyte_private_dns_zone[0].id
  sub_resource          = "blob"
  location              = data.azurerm_resource_group.aks.location
  resource_group_name   = var.aks_vnet_rg_name
  subnet_id             = data.azurerm_subnet.aks_subnet[0].id
}
#########################################################################
############################ Network rules ##############################
#########################################################################
# Create a storage account network rule to authorize access to shared from private endpoint
resource "azurerm_storage_account_network_rules" "domino_shared_rules" {
  count                      = local.private_flyte_enabled ? 1 : 0
  storage_account_id         = azurerm_storage_account.flyte.id
  default_action             = "Deny"
  bypass                     = ["AzureServices"]
  virtual_network_subnet_ids = [data.azurerm_subnet.aks_subnet[0].id]
  depends_on                 = [module.domino_flyte_ep]
}
