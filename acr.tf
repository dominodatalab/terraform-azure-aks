#########################################################################
################################# ACR ###################################
#########################################################################
# Create ACR registry for Domino images
resource "azurerm_container_registry" "domino" {
  #checkov:skip=CKV_AZURE_237: "Ensure dedicated data endpoints are enabled."
  name                          = replace("${data.azurerm_resource_group.aks.name}domino", "/[^a-zA-Z0-9]/", "")
  resource_group_name           = data.azurerm_resource_group.aks.name
  location                      = data.azurerm_resource_group.aks.location
  sku                           = var.private_acr_enabled == true ? "Premium" : var.registry_tier
  admin_enabled                 = false
  data_endpoint_enabled         = (var.registry_tier == "Premium" || var.private_acr_enabled == true) ? true : null
  public_network_access_enabled = (var.registry_tier == "Premium" || var.private_acr_enabled == true) ? false : true
  zone_redundancy_enabled       = (var.registry_tier == "Premium" || var.private_acr_enabled == true)

  retention_policy {
    enabled = (var.registry_tier == "Premium" || var.private_acr_enabled == true)
  }

  tags = var.tags

  dynamic "network_rule_set" {
    for_each = (var.registry_tier == "Premium" || var.private_acr_enabled == true) ? [1] : []
    content {
      default_action = "Deny"
    }
  }
}
#########################################################################
########################## Private DNS Zone #############################
#########################################################################
# create private dns zone for acr
resource "azurerm_private_dns_zone" "acr_private_dns_zone" {
  count               = var.private_acr_enabled ? 1 : 0
  name                = "privatelink.azurecr.io"
  resource_group_name = data.azurerm_resource_group.aks.name
}
# link the dns private zone to the AKS VNET
resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_acr_vnet_link" {
  count                 = var.private_acr_enabled ? 1 : 0
  name                  = "acr-vnet-dns-link"
  resource_group_name   = data.azurerm_resource_group.aks.name
  private_dns_zone_name = azurerm_private_dns_zone.acr_private_dns_zone[0].name
  virtual_network_id    = data.azurerm_virtual_network.aks_vnet[0].id
}
#########################################################################
########################## Private EndPoint #############################
#########################################################################
# Create a private endpoint for the ACR
module "domino_acr_ep" {
  count                 = var.private_acr_enabled ? 1 : 0
  source                = "./modules/private_endpoint"
  resource_id           = azurerm_container_registry.domino.id
  nic_name              = "acr-${var.deploy_id}"
  private_endpoint_name = "acr-${var.deploy_id}"
  private_dns_zone      = azurerm_private_dns_zone.acr_private_dns_zone[0].name
  private_dns_zone_id   = azurerm_private_dns_zone.acr_private_dns_zone[0].id
  sub_resource          = "registry"
  location              = data.azurerm_resource_group.aks.location
  resource_group_name   = data.azurerm_resource_group.aks.name
  subnet_id             = data.azurerm_subnet.aks_subnet[0].id
}
#########################################################################
########################### Role Assignment #############################
#########################################################################
# ACR Pull from AKS nodes
resource "azurerm_role_assignment" "aks_domino_acr" {
  scope                = azurerm_container_registry.domino.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}
# ACR Push from hepheastus
resource "azurerm_role_assignment" "hephaestus_acr" {
  scope                = azurerm_container_registry.domino.id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_user_assigned_identity.hephaestus.principal_id
}
# ACR Pull from private AKS nodes
resource "azurerm_role_assignment" "aks_domino_private_acr" {
  count                = var.private_cluster_enabled ? 1 : 0
  scope                = azurerm_container_registry.domino.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aks_assigned_identity[0].principal_id
}
# ACR Pull from nucleus-frontend
resource "azurerm_role_assignment" "nucleus_acr" {
  scope                = azurerm_container_registry.domino.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.nucleus.principal_id
}
