resource "azurerm_user_assigned_identity" "flyte_controlplane" {
  name                = "flyte_controlplane"
  location            = var.azurerm_resource_group_location
  resource_group_name = var.azurerm_resource_group_name
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "flyte_dataplane" {
  name                = "flyte_dataplane"
  location            = var.azurerm_resource_group_location
  resource_group_name = var.azurerm_resource_group_name
  tags                = var.tags
}

resource "azurerm_federated_identity_credential" "flyteadmin" {
  name                = "flyteadmin"
  resource_group_name = var.azurerm_resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.azurerm_kubernetes_cluster_oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.flyte_controlplane.id
  subject             = "system:serviceaccount:${var.namespaces.platform}:${var.serviceaccount_names.flyteadmin}"
}

resource "azurerm_federated_identity_credential" "flytepropeller" {
  name                = "flytepropeller"
  resource_group_name = var.azurerm_resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.azurerm_kubernetes_cluster_oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.flyte_controlplane.id
  subject             = "system:serviceaccount:${var.namespaces.platform}:${var.serviceaccount_names.flytepropeller}"
}

resource "azurerm_federated_identity_credential" "datacatalog" {
  name                = "datacatalog"
  resource_group_name = var.azurerm_resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.azurerm_kubernetes_cluster_oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.flyte_dataplane.id
  subject             = "system:serviceaccount:${var.namespaces.platform}:${var.serviceaccount_names.datacatalog}"
}
