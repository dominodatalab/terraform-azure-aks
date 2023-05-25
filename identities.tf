resource "azurerm_user_assigned_identity" "hephaestus" {
  name                = "hephaestus"
  location            = data.azurerm_resource_group.aks.location
  resource_group_name = data.azurerm_resource_group.aks.name
}

resource "azurerm_federated_identity_credential" "hephaestus" {
  name                = "hephaestus"
  resource_group_name = data.azurerm_resource_group.aks.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.hephaestus.id
  subject             = "system:serviceaccount:${var.namespaces.platform}:hephaestus"
}
