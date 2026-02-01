# Managed Identity for ACR Credential Refresher
#
# This identity is used by the AcrCredentialRefresher CronJob to:
# 1. Regenerate ACR token passwords
# 2. Update the domino-registry Kubernetes secret
#
# The identity is federated with the Kubernetes service account
# via Workload Identity for secure, credential-less authentication.

# User-assigned managed identity for the credential refresher
resource "azurerm_user_assigned_identity" "acr_credential_refresher" {
  name                = "${var.deploy_id}-acr-credential-refresher"
  resource_group_name = data.azurerm_resource_group.aks.name
  location            = data.azurerm_resource_group.aks.location

  tags = merge(
    var.tags,
    {
      "domino-component" = "acr-credential-refresher"
      "domino-purpose"   = "acr-token-rotation"
    }
  )
}

# Federated identity credential for Kubernetes service account
# Links the Azure managed identity to the Kubernetes service account
# used by the AcrCredentialRefresher CronJob
resource "azurerm_federated_identity_credential" "acr_credential_refresher" {
  name                = "${var.deploy_id}-acr-credential-refresher"
  resource_group_name = data.azurerm_resource_group.aks.name
  parent_id           = azurerm_user_assigned_identity.acr_credential_refresher.id
  audience            = ["api://AzureADTokenExchange"]

  # The service account that will use this identity
  # Format: system:serviceaccount:<namespace>:<serviceaccount-name>
  subject = "system:serviceaccount:${var.namespaces.platform}:acr-credential-refresher"

  # OIDC issuer from AKS cluster
  issuer = azurerm_kubernetes_cluster.aks.oidc_issuer_url

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

# Role assignment: Allow the identity to manage ACR tokens
# This grants the identity permission to regenerate token passwords via Azure Resource Manager API
resource "azurerm_role_assignment" "acr_credential_refresher_contributor" {
  scope                = azurerm_container_registry.domino.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.acr_credential_refresher.principal_id

  # Prevent removal of this role assignment
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    azurerm_user_assigned_identity.acr_credential_refresher
  ]
}
