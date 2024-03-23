locals {
  identities = ["flyte_controlplane", "flyte_dataplane"]
  # Kubernetes service account to user-assigned managed identity mapping
  mapping = {
    flyteadmin     = "flyte_controlplane"
    flytepropeller = "flyte_controlplane"
    datacatalog    = "flyte_controlplane"
    nucleus        = "flyte_dataplane"
  }
}

resource "azurerm_user_assigned_identity" "this" {
  for_each            = toset(local.identities)
  name                = each.key
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_federated_identity_credential" "this" {
  for_each            = local.mapping
  name                = each.key
  resource_group_name = var.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.this[each.value].id
  subject             = "system:serviceaccount:${var.namespaces.platform}:${var.service_account_names[each.key]}"
}
