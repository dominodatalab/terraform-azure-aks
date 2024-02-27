data "azurerm_subscription" "current" {
}

data "azurerm_resource_group" "aks" {
  name = reverse(split("/", var.resource_group))[0]
}

resource "azurerm_role_assignment" "aks_network" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

module "flyte" {
  count                                      = (var.flyte.enabled == true) ? 1 : 0
  source                                     = "./modules/flyte"
  azurerm_container_registry_id              = azurerm_container_registry.domino.id
  azurerm_kubernetes_cluster_oidc_issuer_url = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  azurerm_resource_group_location            = data.azurerm_resource_group.aks.location
  azurerm_resource_group_name                = data.azurerm_resource_group.aks.name
  azurerm_storage_account_name               = azurerm_storage_account.domino.name
  deploy_id                                  = var.deploy_id
  namespaces                                 = var.namespaces
  tags                                       = var.tags
}
