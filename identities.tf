#########################################################################
################## Managed Identities and assignments ###################
#########################################################################
# Create Hephaestus identity
resource "azurerm_user_assigned_identity" "hephaestus" {
  name                = "hephaestus"
  location            = data.azurerm_resource_group.aks.location
  resource_group_name = data.azurerm_resource_group.aks.name
  tags                = var.tags
}
# Create Hephaestus identity credentials
resource "azurerm_federated_identity_credential" "hephaestus" {
  name                = "hephaestus"
  resource_group_name = data.azurerm_resource_group.aks.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.hephaestus.id
  subject             = "system:serviceaccount:${var.namespaces.compute}:hephaestus"
}
# create user assigned identity for AKS
resource "azurerm_user_assigned_identity" "aks_assigned_identity" {
  count               = var.private_cluster_enabled ? 1 : 0
  name                = "aks-${var.deploy_id}"
  location            = data.azurerm_resource_group.aks.location
  resource_group_name = data.azurerm_resource_group.aks.name
  lifecycle {
    ignore_changes = all
  }
}
# Assign identity permissions on fileshare storage account
resource "azurerm_role_assignment" "aks_file_share_contributor" {
  count                = local.private_shared_enabled ? 1 : 0
  scope                = azurerm_storage_account.domino_shared.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = var.private_cluster_enabled ? azurerm_user_assigned_identity.aks_assigned_identity[0].principal_id : azurerm_kubernetes_cluster.aks.identity[0].principal_id
}
# Assign identity permissions on private dns zone
resource "azurerm_role_assignment" "identity_assign_pdnsz" {
  count                = var.private_cluster_enabled ? 1 : 0
  scope                = azurerm_private_dns_zone.aks_private_dns_zone[0].id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_assigned_identity[0].principal_id
  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.private_dns_zone_aks_vnet_link
  ]
}
# Assign identity permissins on resource group
resource "azurerm_role_assignment" "identity_assign_rg" {
  count                = var.private_cluster_enabled ? 1 : 0
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_assigned_identity[0].principal_id
  depends_on = [
    azurerm_user_assigned_identity.aks_assigned_identity
  ]
}
# Assign identity permissins on the vnet
resource "azurerm_role_assignment" "identity_assign_vnet" {
  count                = var.private_cluster_enabled ? 1 : 0
  scope                = data.azurerm_virtual_network.aks_vnet[0].id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_assigned_identity[0].principal_id
  depends_on = [
    azurerm_user_assigned_identity.aks_assigned_identity
  ]
}
# Storage Accounts listKeys from AKS nodes
resource "azurerm_role_assignment" "aks_domino_shared" {
  scope                = azurerm_storage_account.domino_shared.id
  role_definition_name = "Storage Account Key Operator Service Role"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}
# Data importer identity credentials
resource "azurerm_federated_identity_credential" "importer" {
  name                = "importer"
  resource_group_name = data.azurerm_resource_group.aks.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.hephaestus.id
  subject             = "system:serviceaccount:${var.namespaces.platform}:domino-data-importer"
}
