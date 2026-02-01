output "containers" {
  description = "storage details"
  value       = azurerm_storage_container.domino_containers
}

output "storage_account" {
  description = "storage account"
  value       = azurerm_storage_account.domino
}

output "shared_storage_account" {
  description = "shared storage account"
  value       = azurerm_storage_account.domino_shared
}

output "aks_identity" {
  description = "AKS managed identity"
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity[0]
}

output "oidc_issuer_url" {
  description = "OIDC issuer url"
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}

output "domino_acr" {
  description = "Azure Container Registry details"
  value       = azurerm_container_registry.domino
}

output "workload_identities" {
  description = "service identities"
  value = {
    "hephaestus" = azurerm_user_assigned_identity.hephaestus
  }
}
output "blob_dns_zone_name" {
  description = "blob dns zone name"
  value       = var.private_cluster_enabled ? azurerm_private_dns_zone.blob_private_dns_zone[0].name : null
}

output "private_cluster_enabled" {
  description = "Flag to determine if AKS is private or public"
  value       = var.private_cluster_enabled
}

# ACR Token Outputs
output "acr_genai_model_pull_token" {
  description = "ACR repository-scoped token for Gen AI model pulls"
  value = {
    name   = azurerm_container_registry_token.genai_model_pull.name
    id     = azurerm_container_registry_token.genai_model_pull.id
    expiry = var.acr_token_expiry_days
  }
}

output "acr_genai_model_pull_token_name" {
  description = "Name of the ACR token for Gen AI model pulls"
  value       = azurerm_container_registry_token.genai_model_pull.name
}

output "acr_genai_model_pull_token_expiry" {
  description = "Expiry duration in days for ACR token passwords"
  value       = var.acr_token_expiry_days
}

# ACR Credential Refresher Identity Outputs
output "acr_credential_refresher_identity" {
  description = "Managed identity for ACR credential refresher"
  value = {
    client_id    = azurerm_user_assigned_identity.acr_credential_refresher.client_id
    principal_id = azurerm_user_assigned_identity.acr_credential_refresher.principal_id
    id           = azurerm_user_assigned_identity.acr_credential_refresher.id
    name         = azurerm_user_assigned_identity.acr_credential_refresher.name
  }
}

output "acr_credential_refresher_identity_client_id" {
  description = "Client ID of the ACR credential refresher managed identity"
  value       = azurerm_user_assigned_identity.acr_credential_refresher.client_id
}

output "acr_credential_refresher_identity_principal_id" {
  description = "Principal ID of the ACR credential refresher managed identity"
  value       = azurerm_user_assigned_identity.acr_credential_refresher.principal_id
}

output "acr_credential_refresher_identity_id" {
  description = "Resource ID of the ACR credential refresher managed identity"
  value       = azurerm_user_assigned_identity.acr_credential_refresher.id
}

output "acr_credential_refresher_identity_name" {
  description = "Name of the ACR credential refresher managed identity"
  value       = azurerm_user_assigned_identity.acr_credential_refresher.name
}
