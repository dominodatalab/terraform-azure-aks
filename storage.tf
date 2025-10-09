resource "azurerm_storage_account" "domino" {
  name                     = replace(var.deploy_id, "/[_-]/", "")
  location                 = data.azurerm_resource_group.aks.location
  resource_group_name      = data.azurerm_resource_group.aks.name
  account_kind             = "StorageV2"
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  access_tier              = "Hot"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

locals {
  all_containers = merge(
    { for k, v in var.containers : k => merge(v, { name = k }) },
    var.workspace_audit.enabled ? {
      workspace-audit-events-working = {
        name                  = var.workspace_audit.events_container_name
        container_access_type = var.workspace_audit.container_access_type
      }
      workspace-audit-events-archive = {
        name                  = var.workspace_audit.events_archive_container_name
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

  name                  = "${var.deploy_id}-${each.value.name}"
  storage_account_name  = azurerm_storage_account.domino.name
  container_access_type = each.value.container_access_type
}
