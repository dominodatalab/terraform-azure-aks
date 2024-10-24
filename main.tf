data "azurerm_subscription" "current" {
}

data "azurerm_resource_group" "aks" {
  name = reverse(split("/", var.resource_group))[0]
}

resource "azurerm_role_assignment" "aks_network" {
  count                = (var.private_acr_enabled || var.private_cluster_enabled) ? 0 : 1
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}
