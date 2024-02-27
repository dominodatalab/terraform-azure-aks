resource "azurerm_user_assigned_identity" "flyte_controlplane" {
  name                = "flyte_controlplane"
  location            = var.azurerm_resource_group.aks.location
  resource_group_name = var.azurerm_resource_group.aks.name
  tags                = var.tags
}

resource "azurerm_federated_identity_credential" "flyte_controlplane" {
  name                = "flyte_controlplane"
  resource_group_name = var.azurerm_resource_group.aks.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.azurerm_kubernetes_cluster.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.flyte_controlplane.id
  subject             = "system:serviceaccount:${var.namespaces.platform}:flyte_controlplane"
}

resource "azurerm_user_assigned_identity" "flyte_dataplane" {
  name                = "flyte_dataplane"
  location            = var.azurerm_resource_group.aks.location
  resource_group_name = var.azurerm_resource_group.aks.name
  tags                = var.tags
}

resource "azurerm_federated_identity_credential" "flyte_dataplane" {
  name                = "flyte_dataplane"
  resource_group_name = var.azurerm_resource_group.aks.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.azurerm_kubernetes_cluster.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.flyte_dataplane.id
  subject             = "system:serviceaccount:${var.namespaces.compute}:flyte_dataplane"
}

