data "azurerm_subscription" "current" {}

resource "azurerm_dns_zone" "this" {
  name                = var.zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# external-dns identity and DNS Zone Contributor assignment
resource "azurerm_user_assigned_identity" "external_dns" {
  count               = var.external_dns_create ? 1 : 0
  name                = "${var.deploy_id}-external-dns"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  tags                = var.tags
}

resource "azurerm_role_assignment" "external_dns" {
  count                = var.external_dns_create ? 1 : 0
  scope                = azurerm_dns_zone.this.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.external_dns[0].principal_id
}

resource "azurerm_federated_identity_credential" "external_dns" {
  count               = var.external_dns_create ? 1 : 0
  name                = "${var.deploy_id}-external-dns"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.external_dns[0].id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  subject             = "system:serviceaccount:${var.namespaces.platform}:${var.external_dns_service_account}"
}

# cert-manager identity and DNS Zone Contributor assignment
resource "azurerm_user_assigned_identity" "cert_manager" {
  count               = var.cert_manager_create ? 1 : 0
  name                = "${var.deploy_id}-cert-manager"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  tags                = var.tags
}

resource "azurerm_role_assignment" "cert_manager" {
  count                = var.cert_manager_create ? 1 : 0
  scope                = azurerm_dns_zone.this.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.cert_manager[0].principal_id
}

resource "azurerm_federated_identity_credential" "cert_manager" {
  count               = var.cert_manager_create ? 1 : 0
  name                = "${var.deploy_id}-cert-manager"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.cert_manager[0].id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_issuer_url
  subject             = "system:serviceaccount:${var.namespaces.platform}:${var.cert_manager_service_account}"
}
