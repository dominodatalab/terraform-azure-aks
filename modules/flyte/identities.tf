locals {
  identities = ["flyte_controlplane", "flyte_dataplane"]
  # Kubernetes service account to user-assigned managed identity mapping
  mapping = {
    flyteadmin     = "flyte_controlplane"
    flytepropeller = "flyte_controlplane"
    datacatalog    = "flyte_controlplane"
  }
}

resource "azurerm_user_assigned_identity" "this" {
  for_each            = toset(local.identities)
  name                = each.key
  location            = var.azurerm_resource_group_location
  resource_group_name = var.azurerm_resource_group_name
  tags                = var.tags
}

resource "azurerm_federated_identity_credential" "this" {
  for_each            = local.mapping
  name                = each.key
  resource_group_name = var.azurerm_resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.azurerm_kubernetes_cluster_oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.this[each.value].id
  subject             = "system:serviceaccount:${var.namespaces.platform}:${var.serviceaccount_names[each.key]}"
}
