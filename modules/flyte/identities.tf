locals {
  identities = ["controlplane", "dataplane"]
  # Kubernetes service account to user-assigned managed identity mapping
  mapping = {
    flyteadmin     = "controlplane"
    flytepropeller = "controlplane"
    datacatalog    = "controlplane"
    nucleus        = "dataplane"
  }
}

resource "azurerm_user_assigned_identity" "flyte" {
  for_each            = toset(local.identities)
  name                = "${var.deploy_id}-flyte-${each.key}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_federated_identity_credential" "this" {
  for_each            = local.mapping
  name                = "${var.deploy_id}-${each.key}"
  resource_group_name = var.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.flyte[each.value].id
  subject             = "system:serviceaccount:${var.namespaces.platform}:${var.service_account_names[each.key]}"
}
