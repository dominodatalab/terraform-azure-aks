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
  count                      = (var.flyte.enabled == true) ? 1 : 0
  source                     = "./modules/flyte"
  azurerm_container_registry = azurerm_container_registry
  azurerm_kubernetes_cluster = azurerm_kubernetes_cluster
  azurerm_resource_group     = data.azurerm_resource_group
  azurerm_storage_account    = azurerm_storage_account
  deploy_id                  = var.deploy_id
  namespaces                 = var.namespaces
  tags                       = var.tags
}
